import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @StateObject private var authViewModel = AuthViewModel()
    @State private var showEditProfile = false
    @State private var showSettings = false
    @Environment(\.openURL) var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header with Back Button
            HStack(spacing: 16) {
                Button(action: {
                    dismiss()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.lightGreenBg)
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(red: 27 / 255, green: 59 / 255, blue: 54 / 255))  // greenAction
                    }
                    .frame(width: 40, height: 40)
                }

                Text("Profile")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 16)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // Profile Card (Green)
                    Button(action: {
                        showEditProfile = true
                    }) {
                        ZStack(alignment: .bottomTrailing) {
                            // Background
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.lightGreenBg)

                            // Profile Image (Bottom Right)
                            Group {
                                if let imageUrl = appState.currentUser?.profileImage,
                                    let url = URL(string: formatUrl(imageUrl))
                                {
                                    AsyncImage(url: url) { image in
                                        image.resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Color.gray.opacity(0.1)
                                    }
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                } else {
                                    VStack(spacing: 4) {
                                        Circle()
                                            .fill(
                                                Color(
                                                    red: 110 / 255, green: 141 / 255,
                                                    blue: 129 / 255)
                                            )
                                            .frame(width: 40, height: 40)
                                        RoundedRectangle(cornerRadius: 40, style: .continuous)
                                            .fill(
                                                Color(
                                                    red: 110 / 255, green: 141 / 255,
                                                    blue: 129 / 255)
                                            )
                                            .frame(width: 80, height: 40)
                                    }
                                }
                            }
                            .offset(x: 20, y: 30)

                            HStack(alignment: .center) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(appState.currentUser?.name ?? "No Name")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(
                                            Color(red: 27 / 255, green: 59 / 255, blue: 54 / 255))
                                    Text(appState.currentUser?.email ?? "No Email")
                                        .font(.system(size: 15))
                                        .foregroundColor(
                                            Color(red: 27 / 255, green: 59 / 255, blue: 54 / 255))
                                    Text(appState.currentUser?.mobile ?? "No Mobile")
                                        .font(.system(size: 15))
                                        .foregroundColor(
                                            Color(red: 27 / 255, green: 59 / 255, blue: 54 / 255))
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(
                                        Color(red: 27 / 255, green: 59 / 255, blue: 54 / 255))
                            }
                            .padding(20)
                        }
                        .frame(height: 130)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 16)

                    Spacer().frame(height: 32)

                    VStack(spacing: 16) {
                        ProfileOptionCard(icon: "gearshape.fill", title: "App Setting") {
                            showSettings = true
                        }

                        // Logout Button (Red Theme)
                        Button(action: {
                            authViewModel.logout()
                            appState.isLoggedIn = false
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 20))
                                    .foregroundColor(.black)

                                Text("Logout")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)

                                Spacer()
                            }
                            .padding(20)
                            .background(Color(red: 255 / 255, green: 235 / 255, blue: 238 / 255))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        Color(red: 255 / 255, green: 82 / 255, blue: 82 / 255)
                                            .opacity(0.5), lineWidth: 1))
                        }

                        // Delete Account Button (Red Theme)
                        Button(action: {
                            if let url = URL(string: "https://zoobbi.com/business/delete-account") {
                                openURL(url)
                            }
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.red)

                                Text("Delete Account")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.red)

                                Spacer()
                            }
                            .padding(20)
                            .background(Color(red: 255 / 255, green: 235 / 255, blue: 238 / 255))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        Color(red: 255 / 255, green: 82 / 255, blue: 82 / 255)
                                            .opacity(0.5), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .fullScreenCover(isPresented: $showEditProfile) {
            ProfileEditView()
                .environmentObject(appState)
        }
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView()
        }
    }

    private let baseUrl = "https://zoobbi-backend-production.up.railway.app"

    private func formatUrl(_ path: String?) -> String {
        guard let path = path, !path.isEmpty else { return "" }
        if path.hasPrefix("http") { return path }
        if path.hasPrefix("/") { return baseUrl + path }
        return baseUrl + "/" + path
    }
}

struct ProfileOptionCard: View {
    let icon: String
    let title: String
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 27 / 255, green: 59 / 255, blue: 54 / 255))
                    .frame(width: 24)

                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 74 / 255, green: 74 / 255, blue: 74 / 255))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 27 / 255, green: 59 / 255, blue: 54 / 255))
            }
            .padding(16)
            .background(Color(red: 245 / 255, green: 245 / 255, blue: 245 / 255))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
