import Foundation

enum FilterOption: String, CaseIterable, Identifiable {
    case allDeals = "All Deals"
    case nearby = "Nearby"
    case popular = "Popular"
    case recentlyAdded = "Recently Added"

    var id: String { self.rawValue }
}
