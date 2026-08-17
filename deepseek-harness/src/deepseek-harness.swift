// DeepSeek Harness — native macOS wrapper
//
// A minimal, dependency-free WebKit shell: it starts the `dsh web` server (via
// the shared `dsh-app --no-open` launcher), polls the local host until the UI
// responds, then shows it in a real WKWebView window (no browser chrome, no
// Electron download).
//
// Build with the system toolchain, no Xcode project required:
//   swiftc -O -o DeepSeekHarness deepseek-harness.swift \
//     -framework Cocoa -framework WebKit
//
// The binary is then wrapped in a standard .app bundle (see setup.sh).

import Cocoa
import WebKit

// MARK: - Server launcher

/// Start the `dsh-app --no-open` launcher in a child process; it prints to the
/// inherited stdout/stderr so errors are visible to `Console`. We do NOT parse
/// anything from its output — we simply poll the HTTP endpoint until ready.
final class ServerLauncher {
    private let process = Process()
    private let port: Int

    init(port: Int) {
        self.port = port
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        // `--port 0` lets the OS pick a free port, but then the URL is unknown
        // to us; keep it simple and always pass an explicit port. The launcher
        // runs through a login shell so node/npx are on PATH when launched from
        // Finder (whose environment lacks the Homebrew PATH).
        let script = """
        exec "$HOME/.local/bin/dsh-app" --no-open --port \(port)
        """
        process.arguments = ["-lc", script]
        // Inherit stdout/stderr so the dsh-app logs land in Console.app.
        process.standardOutput = FileHandle.standardOutput
        process.standardError = FileHandle.standardError
    }

    func start() {
        try? process.run()
    }

    func terminate() {
        if process.isRunning {
            process.terminate()
        }
    }
}

// MARK: - App delegate

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow!
    private var webView: WKWebView!
    private var launcher: ServerLauncher!
    private var port = 3080

    func applicationDidFinishLaunching(_ notification: Notification) {
        buildMenu()

        // Parse --port from launch args.
        let args = CommandLine.arguments
        if let idx = args.firstIndex(of: "--port"), idx + 1 < args.count {
            port = Int(args[idx + 1]) ?? 3080
        }

        launcher = ServerLauncher(port: port)
        launcher.start()

        // Watch for new windows (links with target=_blank) to open in-place
        // rather than doing nothing.
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()

        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self

        let contentRect = NSRect(x: 0, y: 0, width: 1200, height: 800)
        window = NSWindow(
            contentRect: contentRect,
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "DeepSeek Harness"
        window.contentView = webView
        window.center()
        window.setFrameAutosaveName("DeepSeekHarnessMainWindow")
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(webView)

        // Poll until the server responds (npx may download the package on first
        // run, which can take a while).
        pollUntilReady()
        NSApp.activate(ignoringOtherApps: true)
    }

    private func buildMenu() {
        let mainMenu = NSMenu()

        // App menu
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu
        appMenu.addItem(withTitle: "Quit DeepSeek Harness",
                        action: #selector(NSApplication.terminate(_:)),
                        keyEquivalent: "q")

        // Edit menu — required so Cmd+C / Cmd+V / Cmd+X / Cmd+A reach the
        // WKWebView (which implements the standard responder selectors).
        let editMenuItem = NSMenuItem()
        mainMenu.addItem(editMenuItem)
        let editMenu = NSMenu(title: "Edit")
        editMenuItem.submenu = editMenu
        editMenu.addItem(withTitle: "Undo", action: Selector(("undo:")), keyEquivalent: "z")
        editMenu.addItem(withTitle: "Redo", action: Selector(("redo:")), keyEquivalent: "Z")
        editMenu.addItem(NSMenuItem.separator())
        editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")

        NSApp.mainMenu = mainMenu
    }

    private func pollUntilReady() {
        guard let url = URL(string: "http://127.0.0.1:\(port)/") else {
            showFailure("Invalid port \(port)")
            return
        }
        var attempts = 0
        func tryLoad() {
            attempts += 1
            if attempts > 240 { // ~2 minutes at 0.5s interval
                showFailure("Timed out waiting for the server on port \(port)")
                return
            }
            var req = URLRequest(url: url)
            req.timeoutInterval = 2
            URLSession.shared.dataTask(with: req) { [weak self] data, resp, _ in
                DispatchQueue.main.async {
                    if let http = resp as? HTTPURLResponse, http.statusCode == 200 {
                        self?.webView.load(URLRequest(url: url))
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self?.pollUntilReady() }
                    }
                }
            }.resume()
        }
        tryLoad()
    }

    private func showFailure(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "DeepSeek Harness failed to start"
        alert.informativeText = message + ". Run `dsh-app` in a terminal to see errors."
        alert.runModal()
        NSApp.terminate(nil)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationWillTerminate(_ notification: Notification) {
        launcher?.terminate()
    }
}

// MARK: - WebKit delegates (in-place navigation)

extension AppDelegate: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Load everything in the same window; do not hand off to an external
        // browser (an app should stay self-contained).
        decisionHandler(.allow)
    }
}

extension AppDelegate: WKUIDelegate {
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        // Open target=_blank links in the same WebView.
        webView.load(navigationAction.request)
        return nil
    }
}

// MARK: - main

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
