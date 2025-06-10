import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
  let configuration: WKWebViewConfiguration = {
    let configuration = WKWebViewConfiguration()
    configuration.applicationNameForUserAgent = "nytios/11.29.0; service-worker-enabled"
    configuration.limitsNavigationsToAppBoundDomains = true
    return configuration
  }()

  let messageHandler = MessageHandler()
  let urlRequest: URLRequest
  lazy var webView = WKWebView(frame: .zero, configuration: configuration)

  init(urlRequest: URLRequest) {
    self.urlRequest = urlRequest
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    self.urlRequest = URLRequest(url: URL(string: "https://www.nytimes.com?psw=true&isPreloaded=true")!)
    super.init(coder: coder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    webView.navigationDelegate = self
    webView.configuration.userContentController.add(messageHandler, name: "Foo")
    webView.load(urlRequest)
  }

  override func loadView() {
    view = webView
    webView.isInspectable = true
  }

  func webView(
    _ webView: WKWebView,
    decidePolicyFor navigationAction: WKNavigationAction
  ) async -> WKNavigationActionPolicy {
    let url = navigationAction.request.url!

//    let hostsToBlock = Set([
//      "googlesyndication.com",
//      "google.com",
//      "adtrafficquality.google"
//    ])
//
//    for host in hostsToBlock {
//      if url.host()?.hasSuffix(host) == true {
//        print("blocking navigation:", url)
//        return .cancel
//      }
//    }

    print("navigation:", navigationAction.navigationType.rawValue, url)

    guard navigationAction.navigationType == .linkActivated else {
      return .allow
    }

    navigationController?.pushViewController(
      ViewController(urlRequest: navigationAction.request),
      animated: true
    )

    return .cancel
  }
}

final class MessageHandler: NSObject, WKScriptMessageHandler {
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    print("Received message", message.body)
  }
}
