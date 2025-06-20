# App Bound domain bug example

When a page contains a cross-origin iframe **and** a WKNavigationDelegate returns
WKNavigationActionPolicy.cancel the page loses its App Bound domain status.

Steps to reproduce:

1. Build and load the example app on dev device/simulator
2. Click "Navigate and evaluate JS".
3. Observe "Successfully called JS from app".
4. Click "Add same-domain iframe"
5. Click "Navigate and evaluate JS"
6. Observe "Successfully called JS from app".
7. Click "Add cross-domain iframe"
8. Click "Navigate and evaluate JS"
9. Observe fatal error: "JavaScript execution targeted a frame that is not in an app-bound domain"
