import SwiftUI
import UIKit

struct BusinessProfileView: View {
    let businessId: String
    @Environment(\.dismiss) var dismiss
    @StateObject private var businessVM: BusinessProfileViewModel

    // For Reporting
    @State private var selectedReportDeal: Deal? = nil
    @State private var showReportActionSheet: Bool = false
    @State private var showReportDialog: Bool = false
    @State private var reportReason: String = ""
    @State private var reportDescription: String = ""

    init(businessId: String, homeViewModel: HomeViewModel? = nil) {
        self.businessId = businessId
        _businessVM = StateObject(
            wrappedValue: BusinessProfileViewModel(
                businessId: businessId, homeViewModel: homeViewModel))
    }

    private let baseUrl = "https://zoobbi.com"

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

                // Header Image Area
                ZStack(alignment: .top) {
                    // Background banner image with gradient overlay
                    if let bannerPath = businessVM.business?.images?.first {
                        CachedAsyncImage(url: URL(string: formatUrl(bannerPath))) {
                            ZStack {
                                Color.gray.opacity(0.1)
                                ProgressView()
                            }
                            .frame(height: 280)
                        }
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width, height: 280)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .black.opacity(0.4), .clear, .black.opacity(0.8),
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    } else {
                        Color.gray.opacity(0.3)
                            .frame(height: 280)
                    }

                    VStack(spacing: 0) {
                        // Top Navigation Bar
                        HStack {
                            Button(action: { dismiss() }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(Color.darkGreen)
                                }
                                .frame(width: 36, height: 36)
                            }
                            Spacer()
                            Text("Profile")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            Spacer()
                            Circle().fill(Color.clear).frame(width: 36, height: 36)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 56)

                        Spacer()

                        // Logo & Followers
                        VStack(spacing: 8) {
                            CachedAsyncImage(url: URL(string: formatUrl(businessVM.business?.logo))) {
                                ZStack {
                                    Circle().fill(Color.white)
                                    Text(
                                        businessVM.business?.businessName?.prefix(1).uppercased()
                                            ?? "B"
                                    )
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.red)
                                }
                            }
                            .scaledToFill()
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))

                            VStack(spacing: 2) {
                                Text("Followers").font(.system(size: 12)).foregroundColor(.white)
                                Text(formatFollowerCount(businessVM.business?.followerCount ?? 0))
                                    .font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
                .frame(height: 280)

                // Business Info Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(businessVM.business?.businessName ?? "")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                        Button(action: { businessVM.toggleFollow() }) {
                            ZStack {
                                if businessVM.isFollowLoading {
                                    ProgressView()
                                        .progressViewStyle(AndroidCircularProgressViewStyle(tint: businessVM.isFollowing ? Color.darkGreen : .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text(businessVM.isFollowing ? "Following" : "Follow")
                                        .font(.system(size: 12, weight: .medium))
                                        .lineLimit(1)
                                        .fixedSize(horizontal: true, vertical: false)
                                        .foregroundColor(businessVM.isFollowing ? Color.darkGreen : .white)
                                }
                            }
                            .frame(minWidth: 80)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                businessVM.isFollowing
                                    ? Color(red: 232 / 255, green: 241 / 255, blue: 235 / 255)
                                    : Color.darkGreen
                            )
                            .clipShape(Capsule())
                        }
                        .disabled(businessVM.isFollowLoading)
                    }

                    Text(businessVM.business?.description ?? "")
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 102 / 255, green: 102 / 255, blue: 102 / 255))
                        .lineSpacing(4)

                    if let sl = businessVM.business?.socialLinks {
                        Text("Follow on").font(.system(size: 14, weight: .bold)).foregroundColor(
                            .black
                        ).padding(.top, 8)
                        HStack(spacing: 12) {
                            if let inst = sl.instagram, !inst.isEmpty {
                                SocialIconButton(icon: "skill-icons_instagram") {
                                    businessVM.trackEngagement(action: "web")
                                    openUrl(inst)
                                }
                            }
                            if let fb = sl.facebook, !fb.isEmpty {
                                SocialIconButton(icon: "logos_facebook") {
                                    businessVM.trackEngagement(action: "web")
                                    openUrl(fb)
                                }
                            }
                            if let wa = sl.whatsapp, !wa.isEmpty {
                                SocialIconButton(icon: "logos_whatsapp-icon") {
                                    businessVM.trackEngagement(action: "web")
                                    let phone = wa.filter { $0.isNumber }
                                    openUrl("https://wa.me/\(phone)")
                                }
                            }
                            if let web = sl.website, !web.isEmpty {
                                SocialIconButton(icon: "streamline_web-solid") {
                                    businessVM.trackEngagement(action: "web")
                                    openUrl(web)
                                }
                            }
                        }
                    }

                }
                .padding(16)



                // All Deals Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("All Deals").font(.system(size: 18, weight: .bold)).foregroundColor(.black)
                        .padding(.horizontal, 16)
                    LazyVStack(spacing: 16) {
                        ForEach(businessVM.deals) { deal in
                            DealCard(
                                deal: deal,
                                isFavorite: businessVM.isFavorite(deal._id),
                                distance: "0.1 km away",
                                onCardTap: { businessVM.trackDealView(deal._id) },
                                onFavoriteTap: {
                                    businessVM.homeViewModel?.toggleFavorite(dealId: deal._id)
                                },
                                onEllipsisTap: {
                                    selectedReportDeal = deal
                                    showReportActionSheet = true
                                },
                                onCallTap: { businessVM.trackEngagement(action: "call", dealId: deal._id) },
                                onNavigateTap: {
                                    businessVM.trackEngagement(
                                        action: deal.type == "online" ? "web" : "direction",
                                        dealId: deal._id)
                                }
                            )
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .top)
        .overlay(
            Group {
                if businessVM.isLoading && businessVM.business == nil {
                    ZStack {
                        Color.white.ignoresSafeArea()
                        ProgressView()
                            .progressViewStyle(AndroidCircularProgressViewStyle(tint: .appLoadingGreen))
                    }
                } else if businessVM.business == nil && !businessVM.isLoading {
                    ZStack {
                        Color.white.ignoresSafeArea()
                        VStack(spacing: 20) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("Failed to load business profile")
                                .foregroundColor(.gray)
                            Button("Retry") {
                                businessVM.fetchData()
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(Color.darkGreen)
                            .foregroundColor(.white)
                            .clipShape(Capsule())

                            Button("Go Back") {
                                dismiss()
                            }
                        }
                    }
                }
            }
        )
        // For Reporting
        .actionSheet(isPresented: $showReportActionSheet) {
            ActionSheet(
                title: Text("Options"),
                buttons: [
                    .destructive(Text("Report Deal")) {
                        showReportDialog = true
                    },
                    .cancel(),
                ]
            )
        }
        .sheet(isPresented: $showReportDialog) {
            NavigationView {
                Form {
                    Section(header: Text("Reason")) {
                        TextField("e.g. Inappropriate, Fake, Expired", text: $reportReason)
                    }
                    Section(header: Text("Details")) {
                        TextEditor(text: $reportDescription)
                            .frame(height: 100)
                    }
                }
                .navigationTitle("Report Deal")
                .navigationBarItems(
                    leading: Button("Cancel") { showReportDialog = false },
                    trailing: Button("Submit") {
                        if let dealId = selectedReportDeal?._id {
                            businessVM.reportDeal(
                                dealId: dealId, reason: reportReason, description: reportDescription
                            ) { _ in
                                showReportDialog = false
                                reportReason = ""
                                reportDescription = ""
                            }
                        }
                    }
                    .disabled(reportReason.isEmpty)
                )
            }
        }
    }

    private func formatUrl(_ path: String?) -> String {
        guard let path = path, !path.isEmpty else { return "" }
        if path.hasPrefix("http") { return path }
        if path.hasPrefix("/") { return baseUrl + path }
        return baseUrl + "/" + path
    }

    private func formatFollowerCount(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1000000.0)
        } else if count >= 1000 {
            return String(format: "%.1fk", Double(count) / 1000.0)
        } else {
            return "\(count)"
        }
    }

    private func openUrl(_ urlString: String) {
        var finalUrl = urlString
        if !finalUrl.hasPrefix("http") { finalUrl = "https://" + finalUrl }
        if let url = URL(string: finalUrl) { UIApplication.shared.open(url) }
    }
}

struct SocialIconButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color(red: 232 / 255, green: 235 / 255, blue: 237 / 255))
                    .frame(width: 44, height: 44)
                
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
        }
    }
}
