import Combine
import Foundation
import SwiftUI

class BusinessProfileViewModel: ObservableObject {
    @Published var business: BusinessProfileResponse?
    @Published var deals: [Deal] = []
    @Published var isLoading: Bool = false
    @Published var isFollowing: Bool = false
    @Published var isFollowLoading: Bool = false

    private let api = APIService.shared
    public let homeViewModel: HomeViewModel?
    private var cancellables = Set<AnyCancellable>()
    private let businessId: String

    init(businessId: String, homeViewModel: HomeViewModel? = nil) {
        self.businessId = businessId
        self.homeViewModel = homeViewModel

        if let hvm = homeViewModel {
            self.isFollowing = hvm.isFollowing(businessId)
        }

        fetchData()
    }

    func isFavorite(_ dealId: String) -> Bool {
        return homeViewModel?.isFavorite(dealId) ?? false
    }

    func fetchData() {
        fetchBusinessProfile()
        fetchBusinessDeals()
    }

    func fetchBusinessProfile() {
        isLoading = true
        api.getBusinessProfile(id: businessId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                if case .success(let profile) = result {
                    self?.business = profile
                }
            }
        }
    }

    func fetchBusinessDeals() {
        api.getBusinessDeals(id: businessId) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let fetchedDeals) = result {
                    self?.deals = fetchedDeals
                }
            }
        }
    }

    func toggleFollow() {
        guard let id = business?._id ?? Optional(businessId), !isFollowLoading else { return }
        isFollowLoading = true

        api.toggleFollow(businessId: id) { [weak self] result in
            DispatchQueue.main.async {
                self?.isFollowLoading = false
                if case .success = result {
                    self?.isFollowing.toggle()
                    self?.homeViewModel?.fetchFollowingAndFavorites()
                }
            }
        }
    }

    func trackDealView(_ dealId: String) {
        api.trackDealView(dealId: dealId) { _ in }
    }

    func trackEngagement(action: String, dealId: String? = nil) {
        api.trackEngagement(businessId: businessId, action: action, dealId: dealId) { _ in }
    }

    func reportDeal(
        dealId: String, reason: String, description: String, completion: @escaping (Bool) -> Void
    ) {
        api.reportDeal(dealId: dealId, reason: reason, description: description) { result in
            DispatchQueue.main.async {
                completion(result.isSuccess)
            }
        }
    }
}

extension Result {
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
}
