import Combine
import SwiftUI
import UIKit
import WebKit

@MainActor
final class WebViewStore: ObservableObject {
    static let liveSiteURL = URL(string: "https://osintframework.com")!

    @Published var canGoBack = false
    @Published var canGoForward = false
    @Published var isLoading = false
    @Published var isLiveMode = false
    @Published var safariItem: SafariItem?
    @Published var unsupportedURLString: String?

    weak var webView: WKWebView?

    func loadOfflineHome() {
        isLiveMode = false
        webView?.load(URLRequest(url: BundleSchemeHandler.homeURL))
    }

    func loadLiveSite() {
        isLiveMode = true
        webView?.load(URLRequest(url: Self.liveSiteURL))
    }

    func goBack() {
        webView?.goBack()
    }

    func goForward() {
        webView?.goForward()
    }

    func reload() {
        webView?.reload()
    }

    func openExternalURL(_ url: URL) {
        guard let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              let host = url.host, !host.isEmpty
        else {
            unsupportedURLString = url.absoluteString
            return
        }
        safariItem = SafariItem(url: url)
    }
}

struct WebViewRepresentable: UIViewRepresentable {
    @ObservedObject var store: WebViewStore

    func makeCoordinator() -> Coordinator {
        Coordinator(store: store)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.setURLSchemeHandler(BundleSchemeHandler(), forURLScheme: BundleSchemeHandler.scheme)
        config.allowsInlineMediaPlayback = true
        config.defaultWebpagePreferences.allowsContentJavaScript = true

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.isOpaque = false
        let bgColor = UIColor(red: 0.102, green: 0.102, blue: 0.102, alpha: 1.0)
        webView.backgroundColor = bgColor
        webView.scrollView.backgroundColor = bgColor
        webView.scrollView.alwaysBounceVertical = true

        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(red: 0.290, green: 0.620, blue: 0.855, alpha: 1.0)
        refreshControl.addTarget(
            context.coordinator,
            action: #selector(Coordinator.handleRefresh(_:)),
            for: .valueChanged
        )
        webView.scrollView.refreshControl = refreshControl

        context.coordinator.observe(webView)
        store.webView = webView
        webView.load(URLRequest(url: BundleSchemeHandler.homeURL))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        private let store: WebViewStore
        private var observations: [NSKeyValueObservation] = []

        init(store: WebViewStore) {
            self.store = store
        }

        deinit {
            observations.forEach { $0.invalidate() }
        }

        func observe(_ webView: WKWebView) {
            observations = [
                webView.observe(\.canGoBack, options: [.initial, .new]) { [weak self] wv, _ in
                    Task { @MainActor in
                        self?.store.canGoBack = wv.canGoBack
                    }
                },
                webView.observe(\.canGoForward, options: [.initial, .new]) { [weak self] wv, _ in
                    Task { @MainActor in
                        self?.store.canGoForward = wv.canGoForward
                    }
                },
                webView.observe(\.isLoading, options: [.initial, .new]) { [weak self] wv, _ in
                    Task { @MainActor in
                        self?.store.isLoading = wv.isLoading
                    }
                },
                webView.observe(\.url, options: [.initial, .new]) { [weak self] wv, _ in
                    let isBundled = wv.url?.scheme?.lowercased() == BundleSchemeHandler.scheme
                    Task { @MainActor in
                        self?.store.isLiveMode = !isBundled
                    }
                }
            ]
        }

        @objc func handleRefresh(_ sender: UIRefreshControl) {
            Task { @MainActor in
                store.reload()
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.scrollView.refreshControl?.endRefreshing()
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            webView.scrollView.refreshControl?.endRefreshing()
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            webView.scrollView.refreshControl?.endRefreshing()
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            let scheme = url.scheme?.lowercased() ?? ""
            if scheme == BundleSchemeHandler.scheme || scheme == "about" {
                decisionHandler(.allow)
                return
            }

            if scheme == "http" || scheme == "https" {
                let host = url.host?.lowercased() ?? ""
                if (host == "osintframework.com" || host == "www.osintframework.com") &&
                    navigationAction.targetFrame?.isMainFrame == true
                {
                    decisionHandler(.allow)
                    return
                }
                Task { @MainActor in
                    store.openExternalURL(url)
                }
                decisionHandler(.cancel)
                return
            }

            UIApplication.shared.open(url)
            decisionHandler(.cancel)
        }

        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            if let url = navigationAction.request.url {
                let scheme = url.scheme?.lowercased() ?? ""
                if scheme == "http" || scheme == "https" {
                    Task { @MainActor in
                        store.openExternalURL(url)
                    }
                } else if scheme == BundleSchemeHandler.scheme {
                    webView.load(URLRequest(url: url))
                } else {
                    UIApplication.shared.open(url)
                }
            }
            return nil
        }
    }
}
