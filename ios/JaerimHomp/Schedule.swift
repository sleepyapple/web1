import Foundation

/// 웹사이트의 1.html ~ 7.html 한 페이지에 해당
struct DayPage: Identifiable, Hashable {
    let id: Int
    let label: String
    let heading: String
    var tags: [String] = []
    var lines: [String] = []
}

extension DayPage {
    static let all: [DayPage] = [
        DayPage(id: 1, label: "MON", heading: "시간표",
                lines: ["10:30~12:00 의사소통영어", "13:00~15:00 크로스오버1"]),
        DayPage(id: 2, label: "TUE", heading: "계획",
                tags: ["1/13", "1/14", "1/15"],
                lines: ["교회", "운동", "원피스"]),
        DayPage(id: 3, label: "WED", heading: "시간표"),
        DayPage(id: 4, label: "THU", heading: "시간표", lines: ["야호~ 공강~"]),
        DayPage(id: 5, label: "FRI", heading: "시간표", lines: ["야호~ 공강~~"]),
        DayPage(id: 6, label: "SAT", heading: "시간표", lines: ["토요일"]),
        DayPage(id: 7, label: "SUN", heading: "시간표", lines: ["일요일"]),
    ]

    /// 오늘 요일 (월=1 … 일=7)
    static var today: DayPage {
        let weekday = Calendar.current.component(.weekday, from: Date()) // 일=1 … 토=7
        let id = (weekday + 5) % 7 + 1
        return all.first { $0.id == id } ?? all[0]
    }
}
