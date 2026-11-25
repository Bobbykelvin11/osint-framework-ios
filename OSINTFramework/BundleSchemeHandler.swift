import Foundation
import WebKit

final class BundleSchemeHandler: NSObject, WKURLSchemeHandler {
    static let scheme = "osintapp"
    static let host = "app"
    static let homeURL = URL(string: "\(scheme)://\(host)/index.html")!

    private let webRootURL: URL? = Bundle.main.resourceURL?
        .appendingPathComponent("Web", isDirectory: true)
        .standardizedFileURL

    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url else {
            finishError(urlSchemeTask, code: 400, message: "Invalid URL")
            return
        }

        var relativePath = url.path
        if relativePath.hasPrefix("/") {
            relativePath.removeFirst()
        }
        if relativePath.isEmpty {
            relativePath = "index.html"
        }

        // Handle API endpoints gracefully while offline
        if relativePath.hasPrefix("api/") {
            let body = Data("{\"ok\":false,\"offline\":true}".utf8)
            let response = HTTPURLResponse(
                url: url,
                statusCode: 404,
                httpVersion: "HTTP/1.1",
                headerFields: [
                    "Content-Type": "application/json; charset=utf-8",
                    "Content-Length": "\(body.count)",
                    "Cache-Control": "no-store"
                ]
            )!
            urlSchemeTask.didReceive(response)
            urlSchemeTask.didReceive(body)
            urlSchemeTask.didFinish()
            return
        }

        guard let webRootURL else {
            finishError(urlSchemeTask, code: 500, message: "Bundled web root missing")
            return
        }

        let targetURL = webRootURL.appendingPathComponent(relativePath).standardizedFileURL
        guard targetURL.path.hasPrefix(webRootURL.path),
              FileManager.default.fileExists(atPath: targetURL.path),
              let data = try? Data(contentsOf: targetURL)
        else {
            finishError(urlSchemeTask, code: 404, message: "Resource not found: \(relativePath)")
            return
        }

        let mimeType = mimeType(forPathExtension: targetURL.pathExtension.lowercased())
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: [
                "Content-Type": mimeType,
                "Content-Length": "\(data.count)",
                "Cache-Control": "no-cache"
            ]
        )!

        urlSchemeTask.didReceive(response)
        urlSchemeTask.didReceive(data)
        urlSchemeTask.didFinish()
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        // All responses are delivered synchronously from the app bundle.
    }

    private func finishError(_ task: WKURLSchemeTask, code: Int, message: String) {
        let data = Data(message.utf8)
        let url = task.request.url ?? BundleSchemeHandler.homeURL
        let response = HTTPURLResponse(
            url: url,
            statusCode: code,
            httpVersion: "HTTP/1.1",
            headerFields: [
                "Content-Type": "text/plain; charset=utf-8",
                "Content-Length": "\(data.count)"
            ]
        )!
        task.didReceive(response)
        task.didReceive(data)
        task.didFinish()
    }

    private func mimeType(forPathExtension ext: String) -> String {
        switch ext {
        case "html", "htm":
            return "text/html; charset=utf-8"
        case "js", "mjs":
            return "application/javascript; charset=utf-8"
        case "css":
            return "text/css; charset=utf-8"
        case "json":
            return "application/json; charset=utf-8"
        case "svg":
            return "image/svg+xml"
        case "png":
            return "image/png"
        case "jpg", "jpeg":
            return "image/jpeg"
        case "ico":
            return "image/x-icon"
        default:
            return "application/octet-stream"
        }
    }
}
