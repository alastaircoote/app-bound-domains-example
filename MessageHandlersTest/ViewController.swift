import UIKit
import WebKit

let dummyHTML = """
  <!doctype>
  <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1" />
    </head>
    <body>
      <p>
        <button id='same-domain'>Add same-domain iframe</button>
      </p>
      <p>
        <button id='cross-domain'>Add cross-domain iframe</button>
      </p>
      <p>
        <a href="https://different.example/two.html">Navigate and evaluate JS</a>
      <p>
      <script>
        function addIframe(domain) {
          const el = document.createElement("iframe");
          el.src = `https://${domain}/iframe.html`;
          document.body.appendChild(el);
        }

        document.getElementById('same-domain').addEventListener('click', () => addIframe('test.example'));
        document.getElementById('cross-domain').addEventListener('click', () => addIframe('another.example'));

      </script>
    </body>
  </html>
"""

class ViewController: UIViewController, WKNavigationDelegate {
  let configuration: WKWebViewConfiguration = {
    let configuration = WKWebViewConfiguration()
    configuration.applicationNameForUserAgent = "nytios/11.29.0; service-worker-enabled"
    configuration.limitsNavigationsToAppBoundDomains = true
    return configuration
  }()

  lazy var webView = WKWebView(frame: .zero, configuration: configuration)

  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    webView.navigationDelegate = self
    webView.loadHTMLString(dummyHTML, baseURL: URL(string: "https://test.example/one.html")!)
  }

  override func loadView() {
    view = webView
    webView.isInspectable = true
  }
  
  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {
    
    guard navigationAction.navigationType == .linkActivated else {
      decisionHandler(.allow)
      return
    }
    print("Cancelling navigation")
    decisionHandler(.cancel)
    
    self.webView.evaluateJavaScript("""
      (function() {
        const p = document.createElement('p');
        p.innerHTML = "Successfully called JS from app.";
        document.body.appendChild(p);
      })();
      1+2

    """, in: nil,in: WKContentWorld.defaultClient) { result in
      switch result {
      case .success(let value):
        assert(value as? Int == 3)
        print("Successfully evaluated JavaScript")
      case .failure(let err):
        fatalError(err.localizedDescription)
      }
      
    }
    
  }

}
