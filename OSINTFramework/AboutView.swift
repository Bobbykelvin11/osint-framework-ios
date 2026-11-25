import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var onOpenLink: ((URL) -> Void)?

    private var appVersion: String {
        let short = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(short) (\(build))"
    }

    var body: some View {
        NavigationStack {
            List {
                Section("OSINT Framework for iOS") {
                    LabeledContent("Version", value: appVersion)
                    LabeledContent("Mode", value: "Offline Tree Bundled")
                    Text("The full OSINT Framework directory tree and search index are bundled inside this app so you can browse and search offline. External tool links open inside an in-app Safari browser.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Attribution") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("OSINT Framework")
                            .font(.headline)
                        Text("Created by Justin Nordine (s0lray / lockfale)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)

                    Button {
                        if let url = URL(string: "https://osintframework.com") {
                            dismiss()
                            onOpenLink?(url)
                        }
                    } label: {
                        Label("osintframework.com", systemImage: "globe")
                    }

                    Button {
                        if let url = URL(string: "https://github.com/lockfale/osint-framework") {
                            dismiss()
                            onOpenLink?(url)
                        }
                    } label: {
                        Label("github.com/lockfale/osint-framework", systemImage: "chevron.left.forwardslash.chevron.right")
                    }
                }

                Section("MIT License") {
                    Text(mitLicenseText)
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var mitLicenseText: String {
        """
        MIT License

        Copyright (c) 2017 Justin Nordine (https://github.com/s0lray)

        Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

        The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
        """
    }
}
