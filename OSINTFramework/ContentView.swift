import SwiftUI

struct ContentView: View {
    @StateObject private var store = WebViewStore()
    @State private var showAbout = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                WebViewRepresentable(store: store)
                    .ignoresSafeArea(edges: [.horizontal])

                if store.isLoading {
                    ProgressView()
                        .progressViewStyle(.linear)
                        .tint(Color("AccentColor"))
                }
            }

            Divider()

            HStack(spacing: 0) {
                toolbarButton(systemName: "chevron.left", label: "Back", disabled: !store.canGoBack) {
                    store.goBack()
                }
                Spacer()
                toolbarButton(systemName: "chevron.right", label: "Forward", disabled: !store.canGoForward) {
                    store.goForward()
                }
                Spacer()
                toolbarButton(
                    systemName: "house.fill",
                    label: "Offline Tree",
                    active: !store.isLiveMode
                ) {
                    store.loadOfflineHome()
                }
                Spacer()
                toolbarButton(
                    systemName: "globe",
                    label: "Live Site",
                    active: store.isLiveMode
                ) {
                    store.loadLiveSite()
                }
                Spacer()
                toolbarButton(systemName: "arrow.clockwise", label: "Reload") {
                    store.reload()
                }
                Spacer()
                toolbarButton(systemName: "info.circle", label: "About") {
                    showAbout = true
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        }
        .background(Color(red: 0.102, green: 0.102, blue: 0.102).ignoresSafeArea())
        .preferredColorScheme(.dark)
        .sheet(item: $store.safariItem) { item in
            SafariView(url: item.url)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showAbout) {
            AboutView { url in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    store.openExternalURL(url)
                }
            }
        }
        .alert(
            "Manual URL Template",
            isPresented: Binding(
                get: { store.unsupportedURLString != nil },
                set: { if !$0 { store.unsupportedURLString = nil } }
            )
        ) {
            if let urlStr = store.unsupportedURLString {
                Button("Copy URL") {
                    UIPasteboard.general.string = urlStr
                }
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text(store.unsupportedURLString ?? "")
        }
    }

    private func toolbarButton(
        systemName: String,
        label: String,
        disabled: Bool = false,
        active: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 17, weight: .medium))
                .frame(width: 40, height: 32)
                .foregroundStyle(
                    disabled ? Color.gray.opacity(0.4)
                    : (active ? Color("AccentColor") : Color.white.opacity(0.9))
                )
        }
        .disabled(disabled)
        .accessibilityLabel(label)
    }
}
