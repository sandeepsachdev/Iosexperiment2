import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            SpursView()
                .tabItem {
                    Label("Spurs", systemImage: "soccerball")
                }

            F1View()
                .tabItem {
                    Label("Formula 1", systemImage: "flag.checkered")
                }
        }
        .accentColor(Color("SpursBlue"))
    }
}

#Preview {
    ContentView()
}
