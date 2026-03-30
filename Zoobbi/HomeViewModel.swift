import Combine
import CoreLocation
import Foundation
import SwiftUI

class HomeViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var deals: [Deal] = []
    @Published var isLoading: Bool = false
    @Published var selectedCategory: String = "All"
    @Published var selectedDealType: String = "All Deals"
    @Published var categories: [BusinessCategory] = []
    @Published var dealTypes: [DealType] = []
    @Published var followingIds: Set<String> = []
    @Published var favoriteIds: Set<String> = []
    @Published var favoriteDeals: [Deal] = []
    @Published var followingBusinesses: [FollowingBusiness] = []
    @Published var unfollowingIds: Set<String> = []
    @Published var mutedBusinessIds: Set<String> = []
    @Published var userLocation: CLLocation?
    @Published var errorMessage: String? = nil
    @Published var notifications: [NotificationModel] = []
    @Published var isFollowingLoading: Bool = false

    private let locationManager = CLLocationManager()
    private let api = APIService.shared

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        fetchDeals()
        fetchFollowingAndFavorites()
        fetchDealTypes()
        fetchCategories()
        fetchNotifications()
    }

    func fetchNotifications() {
        print("HomeViewModel: Fetching notifications...")
        api.getNotifications { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let notes):
                    print("HomeViewModel: Successfully fetched \(notes.count) notifications")
                    self.notifications = notes
                case .failure(let error):
                    print(
                        "HomeViewModel: Error fetching notifications: \(error.localizedDescription)"
                    )
                    self.errorMessage =
                        "Failed to load notifications: \(error.localizedDescription)"
                }
            }
        }
    }

    func markNotificationRead(id: String) {
        api.markNotificationRead(id: id) { result in
            DispatchQueue.main.async {
                if case .success = result {
                    self.fetchNotifications()
                }
            }
        }
    }

    func fetchDealTypes() {
        api.getDealTypes { result in
            DispatchQueue.main.async {
                if case .success(let types) = result {
                    self.dealTypes = types
                }
            }
        }
    }

    func fetchCategories() {
        api.getCategories { result in
            DispatchQueue.main.async {
                if case .success(let cats) = result {
                    self.categories = cats
                }
            }
        }
    }

    func fetchDeals() {
        DispatchQueue.main.async {
            self.isLoading = true
        }

        let catParam = selectedCategory == "All" ? nil : selectedCategory
        let typeParam =
            (selectedDealType == "All Deals" || selectedDealType == "All") ? nil : selectedDealType

        let lat = userLocation?.coordinate.latitude
        let lng = userLocation?.coordinate.longitude

        api.getDeals(category: catParam, dealType: typeParam, lat: lat, lng: lng) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let fetchedDeals):
                    self.deals = fetchedDeals
                    self.errorMessage = nil
                case .failure(let error):
                    print("Error fetching deals: \(error)")
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func setCategory(_ category: String) {
        DispatchQueue.main.async {
            self.selectedCategory = category
            self.selectedDealType = "All Deals"
            self.fetchDeals()
        }
    }

    func setDealType(_ type: String) {
        DispatchQueue.main.async {
            self.selectedDealType = type
            
            // Auto-select category if the deal type has one
            if type != "All Deals" && type != "All" {
                if let dealTypeObj = self.dealTypes.first(where: { $0.name == type }),
                   let categoryName = dealTypeObj.category?.name {
                    print("Auto-selecting category: \(categoryName) for deal type: \(type)")
                    self.selectedCategory = categoryName
                }
            } else {
                // If "All Deals" is selected, don't change category automatically, 
                // but user might want to stay in current category or reset to All.
                // Usually "All Deals" means showing everything globally or in current cat.
            }
            
            self.fetchDeals()
        }
    }

    func reportDeal(
        dealId: String, reason: String, description: String, completion: @escaping (Bool) -> Void
    ) {
        api.reportDeal(dealId: dealId, reason: reason, description: description) { result in
            DispatchQueue.main.async {
                switch result {
                case .success: completion(true)
                case .failure: completion(false)
                }
            }
        }
    }

    func fetchFollowingAndFavorites() {
        DispatchQueue.main.async { self.isFollowingLoading = true }
        api.getFollowing { result in
            DispatchQueue.main.async {
                if case .success(let response) = result {
                    self.followingBusinesses = response.following ?? []
                    self.followingIds = Set((response.following ?? []).map { $0._id })
                    self.mutedBusinessIds = Set(response.mutedBusinesses ?? [])
                }
                self.isFollowingLoading = false
            }
        }

        // Favorite IDs are handled by sync with backend usually
        // But we can fetch favorite deals and extract IDs
        api.getFavorites { result in
            DispatchQueue.main.async {
                if case .success(let favorites) = result {
                    self.favoriteDeals = favorites
                    self.favoriteIds = Set(favorites.map { $0._id })
                }
            }
        }
    }

    func toggleFollow(businessId: String) {
        // Set loading state
        DispatchQueue.main.async {
            self.unfollowingIds.insert(businessId)
        }

        api.toggleFollow(businessId: businessId) { _ in
            DispatchQueue.main.async {
                self.unfollowingIds.remove(businessId)
                self.fetchFollowingAndFavorites()
            }
        }
    }

    func toggleMuteNotifications(businessId: String) {
        // Optimistic update
        DispatchQueue.main.async {
            if self.mutedBusinessIds.contains(businessId) {
                self.mutedBusinessIds.remove(businessId)
            } else {
                self.mutedBusinessIds.insert(businessId)
            }
        }

        api.toggleMuteNotifications(businessId: businessId) { result in
            if case .success(let response) = result {
                DispatchQueue.main.async {
                    self.mutedBusinessIds = Set(response.mutedBusinesses ?? [])
                }
            }
        }
    }

    func toggleFavorite(dealId: String) {
        // Optimistic update
        DispatchQueue.main.async {
            if self.favoriteIds.contains(dealId) {
                self.favoriteIds.remove(dealId)
                self.favoriteDeals = self.favoriteDeals.filter { $0._id != dealId }
            } else {
                self.favoriteIds.insert(dealId)
                if let deal = self.deals.first(where: { $0._id == dealId }) {
                    self.favoriteDeals = [deal] + self.favoriteDeals // Newest first!
                }
            }
        }

        api.toggleFavorite(dealId: dealId) { result in
            if case .success(let response) = result {
                DispatchQueue.main.async {
                    self.favoriteIds = Set(response.favorites ?? [])
                    // Do not reset favoriteDeals here to maintain optimistic sorting order
                }
            }
        }
    }

    func isFollowing(_ businessId: String) -> Bool {
        followingIds.contains(businessId)
    }

    func isFavorite(_ dealId: String) -> Bool {
        favoriteIds.contains(dealId)
    }

    func trackDealView(_ dealId: String) {
        api.trackDealView(dealId: dealId) { _ in }
    }

    func trackEngagement(businessId: String, action: String, dealId: String? = nil) {
        api.trackEngagement(businessId: businessId, action: action, dealId: dealId) { _ in }
    }

    func calculateDistance(destLat: Double?, destLng: Double?) -> String {
        guard let userLoc = userLocation, let dLat = destLat, let dLng = destLng else {
            return "0.1 km away"
        }

        let destLoc = CLLocation(latitude: dLat, longitude: dLng)
        let distance = userLoc.distance(from: destLoc)  // distance in meters

        if distance < 1000 {
            return "\(Int(distance)) m away"
        } else {
            return String(format: "%.1f km away", distance / 1000.0)
        }
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.userLocation = location
        // Just fetch deals once we have the first location if we hadn't already
        fetchDeals()
        locationManager.stopUpdatingLocation()
    }
}
