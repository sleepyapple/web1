import Foundation

/// 다른 앱(밀리의서재 등)에서 공유 버튼으로 보내온 항목 하나
struct SharedItem: Identifiable, Codable, Hashable {
    var id = UUID()
    var text: String
    var urlString: String?
    var imageFileName: String?
    var memo: String
    var date: Date

    var url: URL? { urlString.flatMap(URL.init(string:)) }
}
