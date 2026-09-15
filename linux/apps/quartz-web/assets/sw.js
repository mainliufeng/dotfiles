// Minimal service worker so the Workbench is installable as a standalone app.
// It intentionally does not cache API responses; it only satisfies the
// installability requirement for a fetch handler.
self.addEventListener("install", () => self.skipWaiting());
self.addEventListener("activate", (event) => event.waitUntil(self.clients.claim()));
self.addEventListener("fetch", () => {});
