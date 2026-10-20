import SwiftUI

/// 밀리의서재 등에서 공유한 항목 목록
struct SharedListView: View {
    @State private var items: [SharedItem] = []
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            Group {
                if items.isEmpty {
                    ContentUnavailableView(
                        "공유한 항목이 없어요",
                        systemImage: "square.and.arrow.up",
                        description: Text("밀리의서재에서 공유 → \"Jaerim's homp\"를 누르면 여기에 저장돼요.")
                    )
                } else {
                    List {
                        ForEach(items) { item in
                            NavigationLink(value: item) {
                                SharedRow(item: item)
                            }
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .navigationTitle("공유함")
            .navigationDestination(for: SharedItem.self) { item in
                SharedDetailView(item: item)
            }
            .onAppear(perform: reload)
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { reload() }
            }
            .refreshable { reload() }
        }
    }

    private func reload() {
        items = SharedStore.load()
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            SharedStore.delete(items[index])
        }
        reload()
    }
}

struct SharedRow: View {
    let item: SharedItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let image = item.loadImage() {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(item.text.isEmpty ? (item.urlString ?? "이미지") : item.text)
                    .lineLimit(3)
                if !item.memo.isEmpty {
                    Text(item.memo)
                        .font(.footnote)
                        .foregroundStyle(.tint)
                        .lineLimit(1)
                }
                Text(item.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

struct SharedDetailView: View {
    let item: SharedItem

    var body: some View {
        List {
            if let image = item.loadImage() {
                Section {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }
            }
            if !item.text.isEmpty {
                Section("내용") {
                    Text(item.text)
                        .textSelection(.enabled)
                }
            }
            if let url = item.url {
                Section("링크") {
                    Link(url.absoluteString, destination: url)
                        .font(.footnote)
                }
            }
            if !item.memo.isEmpty {
                Section("메모") {
                    Text(item.memo)
                }
            }
            Section {
                Text(item.date.formatted(date: .long, time: .shortened))
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("공유 항목")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ShareLink(item: [item.text, item.urlString ?? ""].filter { !$0.isEmpty }.joined(separator: "\n"))
        }
    }
}

extension SharedItem {
    func loadImage() -> UIImage? {
        guard let name = imageFileName else { return nil }
        return UIImage(contentsOfFile: SharedStore.imageURL(for: name).path)
    }
}
