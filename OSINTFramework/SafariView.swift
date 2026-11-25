import SafariServices
import SwiftUI

struct SafariItem: Identifiable, Equatable {
    let id = UUID()
    let url: URL
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        config.barCollapsingEnabled = true

        let controller = SFSafariViewController(url: url, configuration: config)
        controller.preferredBarTintColor = UIColor(red: 0.102, green: 0.102, blue: 0.102, alpha: 1.0)
        controller.preferredControlTintColor = UIColor(red: 0.290, green: 0.620, blue: 0.855, alpha: 1.0)
        return controller
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
