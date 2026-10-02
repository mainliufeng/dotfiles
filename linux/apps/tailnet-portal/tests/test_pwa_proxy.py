"""Exercise mounted navigation/resources through a real HTTP upstream and proxy."""
import gzip
import http.client
import json
from pathlib import Path
import runpy
import threading
import unittest
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

proxy = runpy.run_path(str(Path(__file__).resolve().parents[1] / 'bin/tailnet-pwa-proxy'))

class Upstream(BaseHTTPRequestHandler):
    def log_message(self, *args): pass
    def do_GET(self):
        path = self.path.split('?')[0]
        if path == '/redirect':
            body, kind, code = b'', 'text/plain', 302
        elif path == '/graph.json':
            body, kind, code = json.dumps({'nodes': [{'href': '/articles/a', 'id': 'a'}, {'href': 'https://external.test/'}]}).encode(), 'application/json', 200
        elif path == '/api/status':
            body, kind, code = b'{"href":"/business-value"}', 'application/json', 200
        else:
            body, kind, code = (b'<html><head><link rel="manifest" href="/manifest.webmanifest"></head>'
                b'<body><a href="/articles/a">Article</a><img src="/asset.png">'
                b'<a href="//external.test/">External</a><script>fetch("/graph.json")</script></body></html>'), 'text/html', 200
        self.send_response(code)
        self.send_header('Content-Type', kind)
        self.send_header('ETag', '"upstream"')
        self.send_header('Cache-Control', 'max-age=3600')
        if path == '/redirect': self.send_header('Location', '/articles/a')
        if kind == 'text/html':
            body = gzip.compress(body)
            self.send_header('Content-Encoding', 'gzip')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        if self.command != 'HEAD': self.wfile.write(body)
    do_HEAD = do_GET

class ProxyTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.servers = []
        cls.upstream = cls.start(Upstream)
        cls.mounted = cls.start(proxy['make_handler'](cls.site('/knowledge')))
        cls.unmounted = cls.start(proxy['make_handler'](cls.site('')))
    @classmethod
    def site(cls, mount):
        return dict(name='test', upstream=f'http://127.0.0.1:{cls.upstream.server_port}',
                    app='Knowledge', short='知识库', icon='icon-entity.png', token_log='', mount=mount)
    @classmethod
    def start(cls, handler):
        server = ThreadingHTTPServer(('127.0.0.1', 0), handler)
        cls.servers.append(server)
        threading.Thread(target=server.serve_forever, daemon=True).start()
        return server
    @classmethod
    def tearDownClass(cls):
        for server in cls.servers: server.shutdown(); server.server_close()
    def request(self, path, method='GET', mounted=True):
        server = self.mounted if mounted else self.unmounted
        conn = http.client.HTTPConnection('127.0.0.1', server.server_port, timeout=3)
        conn.request(method, path)
        response = conn.getresponse()
        result = response.status, dict(response.getheaders()), response.read()
        conn.close()
        return result
    def test_html_navigation_and_resources(self):
        status, headers, body = self.request('/knowledge/')
        html = body.decode()
        self.assertEqual(status, 200)
        self.assertEqual(html.count('rel="manifest"'), 1)
        self.assertIn('href="/knowledge/articles/a"', html)
        self.assertIn('src="/knowledge/asset.png"', html)
        self.assertIn('href="//external.test/"', html)
        self.assertIn('fetch("/knowledge/graph.json")', html)
        self.assertNotIn('Content-Encoding', headers)
        self.assertNotIn('ETag', headers)
        self.assertEqual(headers['Cache-Control'], 'no-cache')
    def test_scoped_metadata_and_worker(self):
        for path in ('/knowledge/__pwa/manifest.webmanifest', '/manifest.webmanifest'):
            status, _, body = self.request(path)
            manifest = json.loads(body)
            self.assertEqual(status, 200)
            for key in ('id', 'start_url', 'scope'): self.assertEqual(manifest[key], '/knowledge/')
            icon = manifest['icons'][0]['src']
            self.assertEqual(self.request(icon)[0], 200)
        _, _, js = self.request('/knowledge/__pwa/register.js')
        self.assertIn(b'scope:"/knowledge/"', js)
        _, headers, _ = self.request('/knowledge/__pwa/sw.js')
        self.assertEqual(headers['Service-Worker-Allowed'], '/knowledge/')
    def test_legacy_navigation_and_upstream_redirects(self):
        self.assertEqual(self.request('/articles/a?x=1')[1]['Location'], '/knowledge/articles/a?x=1')
        self.assertEqual(self.request('/knowledge?x=1')[1]['Location'], '/knowledge/?x=1')
        self.assertEqual(self.request('/knowledge/redirect')[1]['Location'], '/knowledge/articles/a')
    def test_graph_links_and_business_json(self):
        nodes = json.loads(self.request('/knowledge/graph.json')[2])['nodes']
        self.assertEqual(nodes[0]['href'], '/knowledge/articles/a')
        self.assertEqual(nodes[1]['href'], 'https://external.test/')
        self.assertEqual(json.loads(self.request('/knowledge/api/status')[2])['href'], '/business-value')
    def test_head_with_compressed_and_json_upstream(self):
        for path in ('/knowledge/', '/knowledge/graph.json', '/knowledge/__pwa/manifest.webmanifest'):
            status, headers, body = self.request(path, method='HEAD')
            self.assertEqual(status, 200)
            self.assertEqual(body, b'')
            self.assertEqual(int(headers['Content-Length']), len(self.request(path)[2]))
    def test_unmounted_service_retains_behavior(self):
        status, _, html = self.request('/', mounted=False)
        self.assertEqual(status, 200)
        self.assertIn(b'href="/articles/a"', html)
        self.assertIn(b'href="/__pwa/manifest.webmanifest"', html)
        manifest = json.loads(self.request('/__pwa/manifest.webmanifest', mounted=False)[2])
        self.assertEqual(manifest['scope'], '/')
        self.assertEqual(self.request('/redirect', mounted=False)[1]['Location'], '/articles/a')
    def test_rejects_invalid_mount(self):
        with self.assertRaises(ValueError): proxy['make_handler'](self.site('//external'))

if __name__ == '__main__': unittest.main()
