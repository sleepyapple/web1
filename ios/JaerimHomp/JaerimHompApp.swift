import SwiftUI

@main
struct JaerimHompApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            ScheduleView()
                .tabItem { Label("시간표", systemImage: "calendar") }
            SharedListView()
                .tabItem { Label("공유함", systemImage: "books.vertical") }
        }
    }
}

#Preview {
    ContentView()
}
