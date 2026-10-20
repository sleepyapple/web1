import SwiftUI

struct ScheduleView: View {
    @State private var selectedID = DayPage.today.id
    private let blogURL = URL(string: "https://blog.naver.com/yu15000")!

    private var page: DayPage {
        DayPage.all.first { $0.id == selectedID } ?? DayPage.all[0]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Link(destination: blogURL) {
                        Label("jaerim's blog", systemImage: "link")
                    }
                    dayPicker
                    DayContentView(page: page)
                }
                .padding()
            }
            .navigationTitle("Jaerim's homp")
        }
    }

    private var dayPicker: some View {
        HStack(spacing: 6) {
            ForEach(DayPage.all) { day in
                let isSelected = day.id == selectedID
                Button {
                    selectedID = day.id
                } label: {
                    Text(day.label)
                        .font(.caption.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(isSelected ? Color.accentColor : Color(.secondarySystemBackground),
                                    in: RoundedRectangle(cornerRadius: 8))
                        .foregroundStyle(isSelected ? Color.white : Color.primary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct DayContentView: View {
    let page: DayPage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(page.heading)
                .font(.largeTitle.bold())

            if !page.tags.isEmpty {
                HStack {
                    ForEach(page.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.subheadline)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color(.secondarySystemBackground), in: Capsule())
                    }
                }
            }

            if page.lines.isEmpty {
                Text("등록된 내용이 없어요")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(page.lines, id: \.self) { line in
                    Text(line)
                        .font(.title3)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ScheduleView()
}
