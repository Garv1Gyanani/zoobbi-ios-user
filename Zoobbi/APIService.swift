import Foundation
import UIKit

class APIService {
    static let shared = APIService()
    let baseURL = "https://zoobbi.com/api"

    // Cached URLSession for faster repeated requests
    private let cachedSession: URLSession = {
        let cache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,   // 50 MB memory
            diskCapacity: 200 * 1024 * 1024,     // 200 MB disk
            diskPath: "zoobbi_api_cache"
        )
        let config = URLSessionConfiguration.default
        config.urlCache = cache
        config.requestCachePolicy = .useProtocolCachePolicy
        config.timeoutIntervalForRequest = 15
        return URLSession(configuration: config)
    }()

    var rootURL: String {
        baseURL.replacingOccurrences(of: "/api", with: "")
    }

    var token: String? {
        get { UserDefaults.standard.string(forKey: "auth_token") }
        set { UserDefaults.standard.set(newValue, forKey: "auth_token") }
    }

    func clearSession() {
        token = nil
        UserDefaults.standard.removeObject(forKey: "current_user")
    }

    enum APIError: LocalizedError {
        case invalidURL
        case noData
        case decodingError(String)
        case serverError(String)

        var errorDescription: String? {
            switch self {
            case .invalidURL: return "Invalid URL"
            case .noData: return "No data received from server"
            case .decodingError(let details): return "Decoding error: \(details)"
            case .serverError(let message): return message
            }
        }
    }

    func uploadImage(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        let endpoint = "/upload"
        let urlString = baseURL + endpoint
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue(
            "multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(.failure(APIError.noData))
            return
        }

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append(
            "Content-Disposition: form-data; name=\"image\"; filename=\"profile.jpg\"\r\n".data(
                using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let relativeUrl = json["url"] as? String
            {
                completion(.success(relativeUrl))
            } else {
                completion(.failure(APIError.decodingError("Failed to parse upload response")))
            }
        }.resume()
    }

    private func request<T: Codable>(
        endpoint: String,
        method: String = "GET",
        body: [String: Any]? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let path = endpoint.hasPrefix("/") ? endpoint : "/\(endpoint)"
        let urlString = baseURL + path

        guard
            let url = URL(
                string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    ?? urlString)
        else {
            completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = token {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        cachedSession.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.noData))
                return
            }

            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }

            if !(200...299).contains(httpResponse.statusCode) {
                // Try to parse server error message
                if let errorObj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let message = errorObj["message"] as? String
                {
                    completion(.failure(APIError.serverError(message)))
                } else {
                    completion(
                        .failure(
                            APIError.serverError("Server returned error \(httpResponse.statusCode)")
                        ))
                }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                let str = String(data: data, encoding: .utf8) ?? "No readable data"
                print("Decoding error for \(endpoint): \(error). Data: \(str)")
                completion(.failure(APIError.decodingError(error.localizedDescription)))
            }
        }.resume()
    }

    // MARK: - Auth

    func sendOtp(mobile: String, completion: @escaping (Result<[String: String], Error>) -> Void) {
        request(
            endpoint: "users/send-otp", method: "POST", body: ["mobile": mobile, "role": "user"],
            completion: completion)
    }

    func register(details: [String: Any], completion: @escaping (Result<[String: String], Error>) -> Void) {
        request(endpoint: "users/register", method: "POST", body: details, completion: completion)
    }

    func verifyOtp(
        mobile: String, otp: String, completion: @escaping (Result<LoginResponse, Error>) -> Void
    ) {
        request(endpoint: "users/verify-otp", method: "POST", body: ["mobile": mobile, "otp": otp])
        { (result: Result<LoginResponse, Error>) in
            if case .success(let response) = result {
                self.token = response.token
            }
            completion(result)
        }
    }

    func registerProfile(
        details: [String: Any], completion: @escaping (Result<LoginResponse, Error>) -> Void
    ) {
        request(endpoint: "users/profile", method: "POST", body: details) {
            (result: Result<LoginResponse, Error>) in
            if case .success(let response) = result {
                self.token = response.token
            }
            completion(result)
        }
    }

    // MARK: - Deals & Business

    func getDeals(
        category: String? = nil, dealType: String? = nil, lat: Double? = nil, lng: Double? = nil,
        completion: @escaping (Result<[Deal], Error>) -> Void
    ) {
        var endpoint = "deals?"
        if let category = category { endpoint += "category=\(category)&" }
        if let dealType = dealType { endpoint += "offerType=\(dealType)&" }
        if let lat = lat { endpoint += "lat=\(lat)&" }
        if let lng = lng { endpoint += "lng=\(lng)&" }

        request(endpoint: endpoint, completion: completion)
    }

    func getBusinessProfile(
        id: String, completion: @escaping (Result<BusinessProfileResponse, Error>) -> Void
    ) {
        request(endpoint: "business/\(id)", completion: completion)
    }

    func getBusinessDeals(id: String, completion: @escaping (Result<[Deal], Error>) -> Void) {
        request(endpoint: "deals/business/\(id)", completion: completion)
    }

    func toggleFollow(
        businessId: String, completion: @escaping (Result<FollowResponse, Error>) -> Void
    ) {
        request(endpoint: "users/follow/\(businessId)", method: "POST", completion: completion)
    }

    func toggleFavorite(
        dealId: String, completion: @escaping (Result<FavoriteResponse, Error>) -> Void
    ) {
        request(endpoint: "users/favorite/\(dealId)", method: "POST", completion: completion)
    }

    func getFollowing(completion: @escaping (Result<FollowingResponse, Error>) -> Void) {
        request(endpoint: "users/following", completion: completion)
    }

    func toggleMuteNotifications(
        businessId: String, completion: @escaping (Result<MuteResponse, Error>) -> Void
    ) {
        request(endpoint: "users/mute/\(businessId)", method: "POST", completion: completion)
    }

    func getMutedBusinesses(completion: @escaping (Result<MuteResponse, Error>) -> Void) {
        request(endpoint: "users/muted", completion: completion)
    }

    func getFavorites(completion: @escaping (Result<[Deal], Error>) -> Void) {
        request(endpoint: "users/favorites", completion: completion)
    }

    func scanBusiness(
        businessId: String, completion: @escaping (Result<EmptyResponse, Error>) -> Void
    ) {
        request(endpoint: "users/scan/\(businessId)", method: "POST", completion: completion)
    }

    func trackDealView(dealId: String, completion: @escaping (Result<EmptyResponse, Error>) -> Void)
    {
        request(endpoint: "deals/view/\(dealId)", method: "POST", completion: completion)
    }

    func getPublicStates(completion: @escaping (Result<[StateModel], Error>) -> Void) {
        request(endpoint: "users/public/states", completion: completion)
    }

    func getPublicCities(completion: @escaping (Result<[CityModel], Error>) -> Void) {
        request(endpoint: "users/public/cities", completion: completion)
    }

    func trackEngagement(
        businessId: String, action: String, dealId: String? = nil,
        completion: @escaping (Result<EmptyResponse, Error>) -> Void
    ) {
        var body: [String: Any] = ["action": action]
        if let dId = dealId { body["dealId"] = dId }

        request(
            endpoint: "business/\(businessId)/engagement", method: "POST", body: body,
            completion: completion)
    }

    func getDealTypes(completion: @escaping (Result<[DealType], Error>) -> Void) {
        request(endpoint: "users/deal-types", completion: completion)
    }

    func getCategories(completion: @escaping (Result<[BusinessCategory], Error>) -> Void) {
        request(endpoint: "categories", completion: completion)
    }

    func reportDeal(
        dealId: String, reason: String, description: String,
        completion: @escaping (Result<EmptyResponse, Error>) -> Void
    ) {
        request(
            endpoint: "users/report/\(dealId)", method: "POST",
            body: ["reason": reason, "description": description], completion: completion)
    }

    func getNotifications(completion: @escaping (Result<[NotificationModel], Error>) -> Void) {
        request(endpoint: "users/notifications", completion: completion)
    }

    func markNotificationRead(
        id: String, completion: @escaping (Result<NotificationModel, Error>) -> Void
    ) {
        request(endpoint: "users/notifications/\(id)/read", method: "PUT", completion: completion)
    }

    func checkUser(mobile: String, role: String? = nil, completion: @escaping (Result<CheckUserResponse, Error>) -> Void) {
        var endpoint = "users/check/\(mobile)"
        if let role = role { endpoint += "?role=\(role)" }
        request(endpoint: endpoint, completion: completion)
    }
}

struct CheckUserResponse: Codable {
    let exists: Bool
    let isComplete: Bool
    let role: String?
}

struct EmptyResponse: Codable {}
