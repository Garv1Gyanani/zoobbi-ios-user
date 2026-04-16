import SwiftUI

struct ProfileFollowingView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState

    @ObservedObject var homeViewModel: HomeViewModel

    private let baseUrl = "https://zoobbi.com"

    var filteredFollowing: [FollowingBusiness] {
        if searchText.isEmpty {
            return homeViewModel.followingBusinesses
        } else {
            return homeViewModel.followingBusinesses.filter { business in
                (business.businessName ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    @State private var searchText = ""

    // States to handle navigation overlays
    @State private var showNotifications = false
    @State private var showSettings = false
    @State private var showEditProfile = false
    @State private var businessToOpen: BusinessProfileItem? = nil

    var body: some View {
        VStack(spacing: 0) {

            // Header: "Profile", Notifications Button, Settings Button
            HStack(spacing: 12) {
                Text("Profile")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)

                Spacer()

                Button(action: {
                    showNotifications = true
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.lightGreenBg)
                            .frame(width: 40, height: 40)
                        Image(systemName: "bell.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.2))  // Dark green
                    }
                }

                Button(action: {
                    showSettings = true
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.lightGreenBg)
                            .frame(width: 40, height: 40)
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.2))  // Dark green
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Spacer()
                .frame(height: 32)

            // Avatar & Name & Edit Profile Link
            VStack(spacing: 12) {
                if let imageUrl = appState.currentUser?.profileImage, !imageUrl.isEmpty,
                    let url = URL(string: formatUrl(imageUrl))
                {
                    CachedAsyncImage(url: url) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.85, green: 0.85, blue: 0.85))
                                .frame(width: 100, height: 100)
                            Text(
                                String((appState.currentUser?.name ?? "U").prefix(1))
                                    .uppercased()
                            )
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                        }
                    }
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color(red: 0.85, green: 0.85, blue: 0.85))
                        .frame(width: 100, height: 100)
                }

                Text(appState.currentUser?.name ?? "")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)

                Button(action: {
                    showEditProfile = true
                }) {
                    Text("Edit Profile")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        .underline()
                }
            }

            Spacer()
                .frame(height: 40)

            // "Following" Section Header & Search Bar
            VStack(spacing: 16) {
                HStack {
                    Text("Following")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)

                    Spacer()

                    Text("\(homeViewModel.followingBusinesses.count)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                }
                .padding(.horizontal, 24)

                // Search Field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .font(.system(size: 18))

                    TextField("Search", text: $searchText)
                        .font(.system(size: 15))
                }
                .padding()
                .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                .cornerRadius(12)
                .padding(.horizontal, 24)
            }

            Spacer()
                .frame(height: 24)

            // Following Scroll List
            if homeViewModel.isFollowingLoading && homeViewModel.followingBusinesses.isEmpty {
                Spacer()
                ProgressView()
                    .progressViewStyle(AndroidCircularProgressViewStyle(tint: .appLoadingGreen))
                Spacer()
            } else if !homeViewModel.isFollowingLoading && homeViewModel.followingBusinesses.isEmpty {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "person.2.slash")
                        .font(.system(size: 50))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("You're not following any businesses yet")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                Spacer()
            } else {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    ForEach(filteredFollowing) { business in
                        Button(action: {
                            businessToOpen = BusinessProfileItem(id: business._id)
                        }) {
                            HStack(spacing: 16) {

                                // Brand Icon (Network or Placeholder)
                                CachedAsyncImage(url: URL(string: formatUrl(business.logo))) {
                                    ZStack {
                                        Circle().fill(Color(red: 0.85, green: 0.15, blue: 0.15))
                                        Text(
                                            String((business.businessName ?? "U").prefix(1))
                                                .uppercased()
                                        )
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                    }
                                }
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())

                                Text(business.businessName ?? "Unknown Business")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                    .lineLimit(1)

                                Spacer()

                                // Action Buttons
                                HStack(spacing: 12) {
                                    // Mute/Unmute Notifications Button
                                    let isMuted = homeViewModel.mutedBusinessIds.contains(business._id)
                                    Button(action: {
                                        homeViewModel.toggleMuteNotifications(businessId: business._id)
                                    }) {
                                        ZStack {
                                            Circle()
                                                .stroke(
                                                    isMuted
                                                        ? Color.gray.opacity(0.5)
                                                        : Color(red: 0.1, green: 0.3, blue: 0.25),
                                                    lineWidth: 1.5
                                                )
                                                .frame(width: 32, height: 32)
                                            Image(systemName: isMuted ? "bell.slash.fill" : "bell.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(
                                                    isMuted
                                                        ? .gray
                                                        : Color(red: 0.1, green: 0.3, blue: 0.25))
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())

                                    // Delete/Trash Button (Red Outline) or Loading
                                    if homeViewModel.unfollowingIds.contains(business._id) {
                                        ProgressView()
                                            .frame(width: 32, height: 32)
                                    } else {
                                        Button(action: {
                                            homeViewModel.toggleFollow(businessId: business._id)
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .stroke(Color(.red), lineWidth: 1.5)
                                                    .frame(width: 32, height: 32)
                                                Image(systemName: "trash.fill")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.red)
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            } // end else

            Spacer()
        }
        .background(Color.white.ignoresSafeArea())

        // Modal Sheet Overlays based on state flags
        .fullScreenCover(isPresented: $showNotifications) {
            NotificationsView(viewModel: homeViewModel)
        }
        .fullScreenCover(isPresented: $showSettings) {
            ProfileView()
                .environmentObject(appState)
        }
        .fullScreenCover(isPresented: $showEditProfile) {
            ProfileEditView()
        }
        .fullScreenCover(item: $businessToOpen) { item in
            BusinessProfileView(businessId: item.id, homeViewModel: homeViewModel)
        }
    }

    private func formatUrl(_ path: String?) -> String {
        guard let path = path, !path.isEmpty else { return "" }
        if path.hasPrefix("http") { return path }
        if path.hasPrefix("/") { return baseUrl + path }
        return baseUrl + "/" + path
    }
}

struct ProfileFollowingView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileFollowingView(homeViewModel: HomeViewModel())
            .environmentObject(AppState())
    }
}
