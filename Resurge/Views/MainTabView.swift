import SwiftUI

struct MainTabView: View {

    @EnvironmentObject var environment: AppEnvironment
    @State private var selectedTab: Tab = .home
    @AppStorage("selectedTheme") private var selectedTheme: String = "default"
    @AppStorage("quick_hide_enabled") private var quickHideEnabled = false

    enum Tab: String, CaseIterable {
        case home, plan, toolkit, insights, settings
    }

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.appBackground)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().unselectedItemTintColor = UIColor(Color.textSecondary)
    }

    var body: some View {
        ZStack {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.home)

            PlanView()
                .tabItem {
                    Label("Plan", systemImage: "map.fill")
                }
                .tag(Tab.plan)

            ToolkitView()
                .tabItem {
                    Label("Toolkit", systemImage: "wrench.and.screwdriver.fill")
                }
                .tag(Tab.toolkit)

            ProgressDashboardView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.fill")
                }
                .tag(Tab.insights)

            MoreView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(Tab.settings)
        }
        .accentColor(.neonCyan)
        .onChange(of: selectedTheme) { _ in
            // Refresh cached theme colors
            ThemeColors.shared.refresh()
            // Update tab bar UIKit appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.appBackground)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }

            // Full-screen celebration overlay
            CelebrationOverlayView()

            // Badge unlock popup (queued, one at a time)
            BadgeUnlockPopupView()
        }
        .onTapGesture(count: 3) {
            if quickHideEnabled {
                // Triple-tap: minimize app to home screen
                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
            }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AppEnvironment.preview)
            .preferredColorScheme(.dark)
    }
}
