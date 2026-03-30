import SwiftUI

// MARK: - Category (from admin panel)
struct BusinessCategory: Codable, Identifiable, Equatable {
    let _id: String
    let name: String
    let icon: String?
    let isActive: Bool?
    var id: String { _id }
}

// MARK: - Location Model
struct LocationModel: Codable {
    let type: String?
    let coordinates: [Double]?  // [lng, lat]
}

// MARK: - Social Links
struct SocialLinks: Codable {
    let facebook: String?
    let instagram: String?
    let whatsapp: String?
    let website: String?
}

// MARK: - Business Hours
struct BusinessDayHours: Codable {
    let day: String
    let open: String
    let close: String
    let status: String
}

typealias BusinessHours = [String: BusinessDayHours]

// MARK: - Business Deal Info
struct BusinessDealInfo: Codable, Identifiable {
    let _id: String
    let businessName: String?
    let logo: String?
    let phone: String?
    let location: LocationModel?
    let formattedAddress: String?

    var id: String { _id }
}

// MARK: - Deal Model
struct Deal: Codable, Identifiable {
    let _id: String
    let business: BusinessDealInfo?
    let title: String?
    let description: String?
    let image: String?
    let startDate: String?
    let endDate: String?
    let type: String?
    let dealType: String?
    let value: String?
    let category: String?
    let offerType: String?
    let isActive: Bool?
    let link: String?
    let views: Int?

    var id: String { _id }
}

// MARK: - Business Profile Response
struct BusinessProfileResponse: Codable {
    let _id: String
    let businessName: String?
    let description: String?
    let logo: String?
    let category: String?
    let dealViewsCount: Int?
    let followerCount: Int?
    let phone: String?
    let location: LocationModel?
    let formattedAddress: String?
    let socialLinks: SocialLinks?
    let businessHours: BusinessHours?
    let images: [String]?

    enum CodingKeys: String, CodingKey {
        case _id, businessName, description, logo, category, dealViewsCount, followerCount, phone,
            location, formattedAddress, socialLinks, businessHours, images
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decode(String.self, forKey: ._id)
        businessName = try? container.decode(String.self, forKey: .businessName)
        description = try? container.decode(String.self, forKey: .description)
        logo = try? container.decode(String.self, forKey: .logo)
        dealViewsCount = try? container.decode(Int.self, forKey: .dealViewsCount)
        followerCount = try? container.decode(Int.self, forKey: .followerCount)
        phone = try? container.decode(String.self, forKey: .phone)
        location = try? container.decode(LocationModel.self, forKey: .location)
        formattedAddress = try? container.decode(String.self, forKey: .formattedAddress)
        socialLinks = try? container.decode(SocialLinks.self, forKey: .socialLinks)
        businessHours = try? container.decode(BusinessHours.self, forKey: .businessHours)
        images = try? container.decode([String].self, forKey: .images)

        // Flexible category decoding
        if let catString = try? container.decode(String.self, forKey: .category) {
            category = catString
        } else if let catObj = try? container.decode(CategoryWrapper.self, forKey: .category) {
            category = catObj.name
        } else {
            category = nil
        }
    }
}

struct CategoryWrapper: Codable, Equatable {
    let _id: String?
    let name: String?
}

// MARK: - User
struct User: Codable {
    let _id: String
    let name: String?
    let email: String?
    let mobile: String?
    let profileImage: String?
    let token: String?
}

// MARK: - Login Response
struct LoginResponse: Codable {
    let _id: String
    var name: String?
    var email: String?
    var mobile: String?
    let token: String
    var profileImage: String?
    var isProfileComplete: Bool?
}

// MARK: - Follow/Favorite Responses
struct FollowResponse: Codable {
    let following: [String]?
}

struct FavoriteResponse: Codable {
    let favorites: [String]?
}

struct FollowingBusiness: Codable, Identifiable {
    let _id: String
    let businessName: String?
    let logo: String?
    let category: String?

    var id: String { _id }
}

struct FollowingResponse: Codable {
    let following: [FollowingBusiness]?
    let mutedBusinesses: [String]?
}

struct MuteResponse: Codable {
    let mutedBusinesses: [String]?
    let isMuted: Bool?
}

// MARK: - Location Selection Models
struct StateModel: Codable, Identifiable {
    let _id: String
    let name: String
    var id: String { _id }
}

struct CityModel: Codable, Identifiable {
    let _id: String
    let name: String
    let state: String  // State ID
    var id: String { _id }
}

// MARK: - Deal Type (Dynamic)
struct DealType: Codable, Identifiable, Equatable {
    let _id: String
    let name: String
    let isActive: Bool?
    let category: CategoryWrapper?
    var id: String { _id }
}
// MARK: - Navigation Identifiables
struct BusinessProfileItem: Identifiable {
    let id: String
}

// MARK: - Notification Model
struct NotificationModel: Codable, Identifiable {
    let _id: String
    let business: FollowingBusiness?
    let user: String?
    let type: String
    let message: String
    let deal: Deal?
    let isRead: Bool?
    let createdAt: String

    var id: String { _id }
}
