import SwiftUI
import UIKit
import UniformTypeIdentifiers

/// 공유 시트에서 "Jaerim's homp"를 눌렀을 때 뜨는 화면
final class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let inputItems = extensionContext?.inputItems as? [NSExtensionItem] ?? []
        Task { @MainActor in
            let content = await SharedContent.load(from: inputItems)
            show(content)
        }
    }

    private func show(_ content: SharedContent) {
        let shareView = ShareView(
            content: content,
            onCancel: { [weak self] in
                self?.extensionContext?.cancelRequest(
                    withError: NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError))
            },
            onSave: { [weak self] memo in
                content.save(memo: memo)
                self?.extensionContext?.completeRequest(returningItems: nil)
            }
        )
        let host = UIHostingController(rootView: shareView)
        addChild(host)
        host.view.frame = view.bounds
        host.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(host.view)
        host.didMove(toParent: self)
    }
}

/// 공유 시트로 넘어온 텍스트 / 링크 / 이미지
struct SharedContent {
    var text = ""
    var url: URL?
    var imageData: Data?

    var isEmpty: Bool { text.isEmpty && url == nil && imageData == nil }

    func save(memo: String) {
        SharedStore.add(SharedItem(
            text: text,
            urlString: url?.absoluteString,
            imageFileName: imageData.flatMap(SharedStore.saveImage),
            memo: memo.trimmingCharacters(in: .whitespacesAndNewlines),
            date: Date()
        ))
    }

    static func load(from items: [NSExtensionItem]) async -> SharedContent {
        var content = SharedContent()
        var texts: [String] = []

        for item in items {
            if let text = item.attributedContentText?.string {
                texts.append(text)
            }
            for provider in item.attachments ?? [] {
                if content.imageData == nil,
                   provider.hasItemConformingToTypeIdentifier(UTType.image.identifier),
                   let object = try? await provider.loadItem(forTypeIdentifier: UTType.image.identifier) {
                    content.imageData = imageData(from: object)
                    continue
                }
                if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier),
                   let url = try? await provider.loadItem(forTypeIdentifier: UTType.url.identifier) as? URL {
                    if !url.isFileURL, content.url == nil { content.url = url }
                    continue
                }
                if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier),
                   let text = try? await provider.loadItem(forTypeIdentifier: UTType.plainText.identifier) as? String {
                    texts.append(text)
                }
            }
        }

        // 같은 문장이 여러 번 들어오는 경우가 있어 중복 제거
        var seen = Set<String>()
        content.text = texts
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && seen.insert($0).inserted }
            .joined(separator: "\n")

        // 링크가 따로 안 오고 텍스트 안에만 있으면 꺼내 쓴다
        if content.url == nil {
            content.url = firstLink(in: content.text)
        }
        return content
    }

    private static func imageData(from object: NSSecureCoding) -> Data? {
        if let url = object as? URL { return try? Data(contentsOf: url) }
        if let image = object as? UIImage { return image.jpegData(compressionQuality: 0.85) }
        return object as? Data
    }

    private static func firstLink(in text: String) -> URL? {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return nil
        }
        let range = NSRange(text.startIndex..., in: text)
        return detector.firstMatch(in: text, range: range)?.url
    }
}

struct ShareView: View {
    let content: SharedContent
    let onCancel: () -> Void
    let onSave: (String) -> Void

    @State private var memo = ""

    var body: some View {
        NavigationStack {
            Form {
                if content.isEmpty {
                    Section {
                        Text("가져올 수 있는 내용이 없어요.")
                            .foregroundStyle(.secondary)
                    }
                }
                if let data = content.imageData, let image = UIImage(data: data) {
                    Section {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 220)
                    }
                }
                if !content.text.isEmpty {
                    Section("공유된 내용") {
                        Text(content.text)
                            .font(.callout)
                    }
                }
                if let url = content.url {
                    Section("링크") {
                        Text(url.absoluteString)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                Section("메모") {
                    TextField("메모를 남겨보세요 (선택)", text: $memo, axis: .vertical)
                }
            }
            .navigationTitle("공유함에 저장")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") { onSave(memo) }
                        .disabled(content.isEmpty)
                }
            }
        }
    }
}
