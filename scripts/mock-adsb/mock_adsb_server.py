#!/usr/bin/env python3
import http.server
import os
import socketserver

PORT = 18090
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
JSON_FILE = os.path.join(BASE_DIR, "aircraft.json")


class AdsbMockHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        try:
            with open(JSON_FILE, "rb") as f:
                payload = f.read()
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(payload)))
            self.end_headers()
            self.wfile.write(payload)
        except Exception as e:
            err = f'{{"error": "{str(e)}"}}'.encode("utf-8")
            self.send_response(500)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(err)


class ReusableTCPServer(socketserver.TCPServer):
    allow_reuse_address = True


if __name__ == "__main__":
    with ReusableTCPServer(("0.0.0.0", PORT), AdsbMockHandler) as httpd:
        print(f"Mock ADS-B server listening on http://0.0.0.0:{PORT} serving {JSON_FILE}", flush=True)
        httpd.serve_forever()
