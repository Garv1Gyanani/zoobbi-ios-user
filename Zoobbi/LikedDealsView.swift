import SwiftUI

struct LikedDealsView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(red: 0.05, green: 0.24, blue: 0.24))
                    }
                    .frame(width: 36, height: 36)
                    .shadow(color: .black.opacity(0.1), radius: 4)
                }

                Spacer()

                Text("Liked Deals")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)

                Spacer()

                // Empty placeholder for balance
                Circle()
                    .fill(Color.clear)
                    .frame(width: 36, height: 36)
            }
            .padding(.horizontal, 16)
            .padding(.top, 60)
            .padding(.bottom, 20)
            .background(Color.white)

            // Content
            ScrollView(showsIndicators: false) {
                let likedDeals = viewModel.favoriteDeals

                if likedDeals.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                            .frame(height: 100)
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.3))
                        Text("No liked deals yet")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.gray)
                        Text("Deals you favorite will appear here.")
                            .font(.system(size: 14))
                            .foregroundColor(.gray.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(likedDeals) { deal in
                            DealCard(
                                deal: deal,
                                isFavorite: true,
                                distance: viewModel.calculateDistance(
                                    destLat: deal.business?.location?.coordinates?.last,
                                    destLng: deal.business?.location?.coordinates?.first
                                ),
                                onCardTap: {
                                    // Navigate to business or detail?
                                },
                                onFavoriteTap: {
                                    viewModel.toggleFavorite(dealId: deal._id)
                                },
                                onEllipsisTap: {
                                    // Report?
                                },
                                onCallTap: {
                                    viewModel.trackEngagement(
                                        businessId: deal.business?._id ?? "", action: "call",
                                        dealId: deal._id)
                                },
                                onNavigateTap: {
                                    viewModel.trackEngagement(
                                        businessId: deal.business?._id ?? "",
                                        action: deal.type == "online" ? "web" : "direction",
                                        dealId: deal._id)
                                }
                            )
                        }
                    }
                    .padding(16)
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color.white.ignoresSafeArea())
    }
}
