import SwiftUI

@main
struct IronCadenceApp: App {
    @StateObject private var store = AppStore()
    @StateObject private var health = HealthKitManager()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .environmentObject(health)
                .tint(Theme.olive)
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active {
                        Task { await health.refresh() }
                    }
                }
        }
    }
}

struct RootView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        if store.profile == nil {
            OnboardingView()
        } else {
            MainTabView()
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Today", systemImage: "scope") }
            ProgramView()
                .tabItem { Label("Program", systemImage: "calendar") }
            ExerciseLibraryView()
                .tabItem { Label("Drills", systemImage: "figure.strengthtraining.functional") }
            NutritionView()
                .tabItem { Label("Fuel", systemImage: "fork.knife") }
            SettingsView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
    }
}
