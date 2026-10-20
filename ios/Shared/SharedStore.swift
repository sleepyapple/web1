import Foundation

/// 앱과 공유 확장(Share Extension)이 같이 쓰는 저장소.
/// App Group 폴더에 JSON 파일과 이미지를 저장한다.
enum SharedStore {
    static var appGroupID: String {
        Bundle.main.object(forInfoDictionaryKey: "AppGroupID") as? String ?? ""
    }

    static var containerURL: URL {
        if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            return url
        }
        // App Group이 설정되지 않았으면 자기 폴더를 쓴다 (이 경우 앱과 확장이 데이터를 공유하지 못함)
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private static var fileURL: URL {
        containerURL.appendingPathComponent("shared-items.json")
    }

    private static var imagesURL: URL {
        let url = containerURL.appendingPathComponent("images", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    static func load() -> [SharedItem] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([SharedItem].self, from: data)) ?? []
    }

    static func save(_ items: [SharedItem]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    static func add(_ item: SharedItem) {
        var items = load()
        items.insert(item, at: 0)
        save(items)
    }

    static func delete(_ item: SharedItem) {
        if let name = item.imageFileName {
            try? FileManager.default.removeItem(at: imageURL(for: name))
        }
        save(load().filter { $0.id != item.id })
    }

    static func saveImage(_ data: Data) -> String? {
        let name = UUID().uuidString + ".jpg"
        do {
            try data.write(to: imageURL(for: name), options: .atomic)
            return name
        } catch {
            return nil
        }
    }

    static func imageURL(for name: String) -> URL {
        imagesURL.appendingPathComponent(name)
    }
}
