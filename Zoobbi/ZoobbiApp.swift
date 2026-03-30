import Combine
import SwiftUI

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false {
        didSet {
            if isLoggedIn {
                loadCurrentUser()
            } else {
                currentUser = nil
            }
        }
    }

    @Published var currentUser: LoginResponse?
    @Published var deepLinkBusinessId: String?

    init() {
        self.isLoggedIn = UserDefaults.standard.string(forKey: "auth_token") != nil
        if self.isLoggedIn {
            loadCurrentUser()
        }
    }

    func loadCurrentUser() {
        if let data = UserDefaults.standard.data(forKey: "current_user"),
            let user = try? JSONDecoder().decode(LoginResponse.self, from: data)
        {
            self.currentUser = user
        }
    }

    func saveCurrentUser() {
        if let user = currentUser, let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: "current_user")
        }
    }
}

@main
struct ZoobbiApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isLoggedIn {
                    HomeView()
                        .environmentObject(appState)
                } else {
                    LoginView()
                        .environmentObject(appState)
                }
            }
            .preferredColorScheme(.light)
            .onOpenURL { url in
                handleDeepLink(url)
            }
        }
    }

    private func handleDeepLink(_ url: URL) {
        // Expected format: https://zoobbi.com/business/{id}
        let pathComponents = url.pathComponents
        if let index = pathComponents.firstIndex(of: "business"), index + 1 < pathComponents.count {
            let businessId = pathComponents[index + 1]
            appState.deepLinkBusinessId = businessId
        }
    }
}
