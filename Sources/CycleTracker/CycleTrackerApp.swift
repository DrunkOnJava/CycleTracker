import SwiftUI

@main
struct CycleTrackerApp: App {
    @StateObject private var cycleLogVM = CycleLogViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(cycleLogVM)
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var cycleLogVM: CycleLogViewModel
    
    var body: some View {
        TabView {
            DashboardView(cycleLogVM: cycleLogVM)
                .tabItem {
                    Label("Dashboard", systemImage: "chart.xyaxis.line")
                }
            
            LogEntryView(cycleLogVM: cycleLogVM)
                .tabItem {
                    Label("Log", systemImage: "square.and.pencil")
                }
            
            CalendarView(cycleLogVM: cycleLogVM)
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
            
            SettingsView(cycleLogVM: cycleLogVM)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(CycleLogViewModel())
}
