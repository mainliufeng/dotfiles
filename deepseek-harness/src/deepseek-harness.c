// DeepSeek Harness — native Linux wrapper
//
// A minimal, dependency-free WebKitGTK shell: it starts the `dsh web` server
// (via the shared `dsh-app --no-open` launcher), polls the local host until the
// UI responds, then shows it in a real WebKitWebView window (no browser chrome,
// no Electron download). This is the Linux sibling of the macOS WKWebView shell.
//
/*
 * Build (Arch):  gcc $(pkg-config --cflags --libs gtk+-3.0 webkit2gtk-4.1) \
 *                    -o deepseek-harness deepseek-harness.c
 *
 * Dependencies:  gtk3, webkit2gtk-4.1  (see setup.sh for the package install)
 */

#include <gtk/gtk.h>
#include <webkit2/webkit2.h>
#include <glib.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <unistd.h>

static GPid server_pid = 0;
static int port = 3080;
static GtkWidget *webview = NULL;
static int ready = 0;
static int poll_count = 0;

/* Poll the server until the TCP port accepts a connection, then load the UI. */
static gboolean poll_ready(gpointer user_data) {
    (void)user_data;
    char url[256];
    if (poll_count++ > 240) { /* ~2 minutes at 0.5s */
        g_printerr("Timed out waiting for the server on port %d\n", port);
        gtk_main_quit();
        return G_SOURCE_REMOVE;
    }
    snprintf(url, sizeof(url), "http://127.0.0.1:%d/", port);

    GSocketClient *client = g_socket_client_new();
    GError *err = NULL;
    GSocketConnection *conn = g_socket_client_connect_to_host(
        client, "127.0.0.1", (guint16)port, NULL, &err);

    if (conn != NULL) {
        g_object_unref(conn);
        g_object_unref(client);
        ready = 1;
        webkit_web_view_load_uri(WEBKIT_WEB_VIEW(webview), url);
        return G_SOURCE_REMOVE;
    }
    g_object_unref(client);
    if (err) {
        g_clear_error(&err);
    }
    return G_SOURCE_CONTINUE;
}

/* Called when the WebView's own load fails while the page is still coming up. */
static void on_load_failed(WebKitWebView *view, WebKitLoadEvent load_event,
                           gchar *failing_uri, GError *error, gpointer user_data) {
    (void)view; (void)load_event; (void)failing_uri; (void)user_data;
    if (!ready) {
        /* Server not up yet — keep polling. */
        return;
    }
    g_printerr("load failed: %s\n", error ? error->message : "unknown");
}

static void on_destroy(GtkWidget *widget, gpointer user_data) {
    (void)widget; (void)user_data;
    if (server_pid > 0) {
        kill(server_pid, SIGTERM);
    }
    gtk_main_quit();
}

static void activate(GtkApplication *app, gpointer user_data) {
    (void)user_data;

    GtkWidget *window = gtk_application_window_new(app);
    gtk_window_set_title(GTK_WINDOW(window), "DeepSeek Harness");
    gtk_window_set_default_size(GTK_WINDOW(window), 1200, 800);
    gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_CENTER);

    // Persistent site data (cookies / localStorage / cache) under the app's
    // own directory, so sessions survive across launches.
    gchar *data_dir = g_build_filename(g_get_user_data_dir(),
                                       "deepseek-harness", NULL);
    gchar *cache_dir = g_build_filename(g_get_user_cache_dir(),
                                        "deepseek-harness", NULL);
    WebKitWebsiteDataManager *wdm = webkit_website_data_manager_new(
        "base-data-directory", data_dir,
        "base-cache-directory", cache_dir,
        NULL);
    g_free(data_dir);
    g_free(cache_dir);

    WebKitWebContext *context = webkit_web_context_new_with_website_data_manager(wdm);
    webkit_web_context_set_cache_model(context, WEBKIT_CACHE_MODEL_WEB_BROWSER);

    webview = webkit_web_view_new_with_context(context);

    // Clipboard / editing: enable the default context menu (right-click Paste)
    // and the built-in editing commands so Ctrl+C/V/X work on inputs.
    WebKitSettings *settings = webkit_web_view_get_settings(WEBKIT_WEB_VIEW(webview));
    webkit_settings_set_enable_default_context_menu(settings, TRUE);
    webkit_settings_set_enable_javascript(settings, TRUE);
    webkit_settings_set_enable_javascript_markup(settings, TRUE);

    gtk_container_add(GTK_CONTAINER(window), webview);
    g_signal_connect(webview, "load-failed", G_CALLBACK(on_load_failed), NULL);
    g_signal_connect(window, "destroy", G_CALLBACK(on_destroy), NULL);

    gtk_widget_show_all(window);

    /* Start polling for readiness; the server child was spawned before run(). */
    g_timeout_add(500, poll_ready, NULL);
}

static void spawn_server(void) {
    /* Resolve dsh-app, then run it with --no-open so it does not open a browser. */
    const char *sh = "/bin/sh";
    char *script = g_strdup_printf(
        "exec \"$HOME/.local/bin/dsh-app\" --no-open --port %d", port);
    gchar *argv[] = { (gchar *)sh, (gchar *)"-c", script, NULL };
    GError *err = NULL;
    if (!g_spawn_async(NULL, argv, NULL, G_SPAWN_SEARCH_PATH | G_SPAWN_DO_NOT_REAP_CHILD,
                       NULL, NULL, &server_pid, &err)) {
        g_printerr("failed to spawn dsh-app: %s\n", err ? err->message : "unknown");
        exit(1);
    }
    g_free(script);
}

int main(int argc, char **argv) {
    /* Parse --port */
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--port") == 0 && i + 1 < argc) {
            port = atoi(argv[i + 1]);
        }
    }

    spawn_server();

    GtkApplication *app = gtk_application_new("dev.mainliufeng.deepseek-harness",
                                              G_APPLICATION_DEFAULT_FLAGS);
    g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);
    int status = g_application_run(G_APPLICATION(app), argc, argv);
    g_object_unref(app);

    if (server_pid > 0) {
        kill(server_pid, SIGTERM);
    }
    return status;
}
