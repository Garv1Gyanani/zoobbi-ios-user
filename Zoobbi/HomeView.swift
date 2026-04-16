import CoreLocation
import SwiftUI

// MARK: - Home View
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: Int = 0
    @State private var showFilter: Bool = false
    @State private var selectedFilter: String = "All Deals"
    @State private var businessToOpen: BusinessProfileItem? = nil
    @State private var showQRScanner: Bool = false
    @State private var showLikedDeals: Bool = false

    // For Reporting
    @State private var selectedReportDeal: Deal? = nil
    @State private var showReportActionSheet: Bool = false
    @State private var showReportDialog: Bool = false
    @State private var reportReason: String = ""
    @State private var reportDescription: String = ""

    var body: some View {
        ZStack(alignment: .trailing) {

            // ── Background + scrollable content + tab bar ──
            ZStack(alignment: .bottom) {
                Color.white.ignoresSafeArea()  // Ensure the background is always white

                VStack(spacing: 0) {
                    if selectedTab == 0 {
                        // Header Section
                        VStack(spacing: 0) {
                            // Top bar
                            HStack {
                                HStack(spacing: 8) {
                                    Image("ic_location_custom")
                                        .resizable()
                                        .renderingMode(.template)
                                        .scaledToFit()
                                        .foregroundColor(.darkGreen)
                                        .frame(width: 16, height: 16)
                                        .padding(.leading, 6)
                                    Text(viewModel.cityName)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.black)
                                }
                                Spacer()
                                HStack(spacing: 16) {
                                    Button(action: {
                                        showLikedDeals = true
                                    }) {
                                        Image(systemName: "heart")
                                            .foregroundColor(.red)
                                            .font(.system(size: 16))
                                            .frame(width: 35, height: 35)
                                            .background(Color.lightGreenBg)
                                            .clipShape(Circle())
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    Button(action: { showFilter = true }) {
                                        Image(systemName: "line.3.horizontal")
                                            .foregroundColor(.darkGreen)
                                            .font(.system(size: 16))
                                            .frame(width: 35, height: 35)
                                            .background(Color.lightGreenBg)
                                            .clipShape(Circle())
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 2)
                            .padding(.bottom, 6)

                            // Category pills
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    // Static "All" chip
                                    Button(action: { viewModel.setCategory("All") }) {
                                        Text("All")
                                            .font(.system(size: 14, weight: viewModel.selectedCategory == "All" ? .semibold : .medium))
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 8)
                                            .background(
                                                viewModel.selectedCategory == "All"
                                                    ? Color(red: 0.05, green: 0.24, blue: 0.24)
                                                    : Color(red: 0.949, green: 0.965, blue: 0.965)  // #F2F6F6
                                            )
                                            .foregroundColor(
                                                viewModel.selectedCategory == "All"
                                                    ? .white : .black
                                            )
                                            .clipShape(Capsule())
                                    }

                                    ForEach(viewModel.categories) { cat in
                                        Button(action: { viewModel.setCategory(cat.name) }) {
                                            Text(cat.name)
                                                .font(.system(size: 14, weight: viewModel.selectedCategory == cat.name ? .semibold : .medium))
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 8)
                                                .background(
                                                    viewModel.selectedCategory == cat.name
                                                        ? Color(red: 0.05, green: 0.24, blue: 0.24)
                                                        : Color(red: 0.949, green: 0.965, blue: 0.965)
                                                )
                                                .foregroundColor(
                                                    viewModel.selectedCategory == cat.name
                                                        ? .white : .black
                                                )
                                                .clipShape(Capsule())
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                            .padding(.bottom, 8)
                        }
                        .background(Color.white)

                        // Deals Area
                        ZStack {
                            Color.white.ignoresSafeArea()

                            if viewModel.isLoading && viewModel.deals.isEmpty {
                                ProgressView()
                            } else if !viewModel.isLoading && viewModel.deals.isEmpty {
                                VStack(spacing: 20) {
                                    Image(
                                        systemName: viewModel.errorMessage == nil
                                            ? "tag.slash" : "exclamationmark.triangle"
                                    )
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray.opacity(0.5))
                                    Text(
                                        viewModel.errorMessage ?? "No deals found in this category"
                                    )
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                                    Button("Retry") {
                                        viewModel.fetchDeals()
                                    }
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 10)
                                    .background(Color(red: 0.05, green: 0.24, blue: 0.24))
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                                }
                            } else {
                                ScrollView(showsIndicators: false) {
                                    LazyVStack(spacing: 16) {
                                        ForEach(viewModel.deals) { deal in
                                            DealCard(
                                                deal: deal,
                                                isFavorite: viewModel.isFavorite(deal._id),
                                                distance: viewModel.calculateDistance(
                                                    destLat: deal.business?.location?.coordinates?
                                                        .last,
                                                    destLng: deal.business?.location?.coordinates?
                                                        .first),
                                                onCardTap: {
                                                    viewModel.trackDealView(deal._id)
                                                    if let bId = deal.business?._id {
                                                        businessToOpen = BusinessProfileItem(
                                                            id: bId)
                                                    }
                                                },
                                                onFavoriteTap: {
                                                    viewModel.toggleFavorite(dealId: deal._id)
                                                },
                                                onEllipsisTap: {
                                                    selectedReportDeal = deal
                                                    showReportActionSheet = true
                                                },
                                                onCallTap: {
                                                    viewModel.trackDealView(deal._id)
                                                    viewModel.trackEngagement(
                                                        businessId: deal.business?._id ?? "",
                                                        action: "call",
                                                        dealId: deal._id)
                                                },
                                                onNavigateTap: {
                                                    viewModel.trackDealView(deal._id)
                                                    viewModel.trackEngagement(
                                                        businessId: deal.business?._id ?? "",
                                                        action: deal.type == "online"
                                                            ? "web" : "direction",
                                                        dealId: deal._id)
                                                })
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.top, 8)
                                    .padding(.bottom, 120)
                                }
                                .refreshable {
                                    viewModel.fetchDeals()
                                }
                            }
                        }
                    } else if selectedTab == 1 {
                        // Direct trigger handled by onChange below
                        Color.white
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if selectedTab == 2 {
                        ProfileFollowingView(homeViewModel: viewModel)
                            .environmentObject(appState)
                    } else {
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, 60)  // Offset for CustomTabBar
                .ignoresSafeArea(edges: .bottom)

                // Tab bar pinned at bottom - Using Custom component
                CustomTabBar(selectedTab: $selectedTab)

            }
            .ignoresSafeArea(edges: .bottom)
            .fullScreenCover(item: $businessToOpen) { item in
                BusinessProfileView(businessId: item.id, homeViewModel: viewModel)
            }

            // ── Filter Drawer (slides over everything) ──
            FilterDrawer(
                isShowing: $showFilter, selectedFilter: $selectedFilter,
                dealTypes: viewModel.selectedCategory == "All" ? viewModel.dealTypes : viewModel.dealTypes.filter { $0.category?.name == viewModel.selectedCategory })
        }
        .fullScreenCover(isPresented: $showQRScanner) {
            QRCodeScannerView { bId in
                businessToOpen = BusinessProfileItem(id: bId)
            }
        }
        .fullScreenCover(isPresented: $showLikedDeals) {
            LikedDealsView(viewModel: viewModel)
        }
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
                            viewModel.reportDeal(
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
        .onChange(of: selectedFilter) { newValue in
            viewModel.setDealType(newValue)
        }
        .onChange(of: selectedTab) { newValue in
            if newValue == 1 {
                showQRScanner = true
            }
        }
        .onChange(of: showQRScanner) { isShown in
            if !isShown && selectedTab == 1 {
                selectedTab = 0
            }
        }
        .onChange(of: appState.deepLinkBusinessId) { newId in
            if let id = newId {
                businessToOpen = BusinessProfileItem(id: id)
                appState.deepLinkBusinessId = nil  // Reset after opening
            }
        }
    }
}
