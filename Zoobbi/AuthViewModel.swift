import Combine
import Foundation
import SwiftUI
import UIKit

class AuthViewModel: ObservableObject {
    @Published var mobileNumber: String = ""
    @Published var otpCode: String = ""
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var isOtpSent: Bool = false
    @Published var isVerified: Bool = false
    @Published var isProfileComplete: Bool = false

    @Published var states: [StateModel] = []
    @Published var allCities: [CityModel] = []
    @Published var filteredCities: [CityModel] = []
    @Published var profileImage: UIImage?
    @Published var profileImageUrl: String?

    private let api = APIService.shared

    init() {
        fetchLocations()
    }

    func fetchLocations() {
        api.getPublicStates { result in
            if case .success(let states) = result {
                DispatchQueue.main.async {
                    self.states = states
                }
            }
        }
        api.getPublicCities { result in
            if case .success(let cities) = result {
                DispatchQueue.main.async {
                    self.allCities = cities
                }
            }
        }
    }

    func filterCities(stateName: String) {
        let stateId = states.first(where: { $0.name == stateName })?._id
        if let stateId = stateId {
            filteredCities = allCities.filter { $0.state == stateId }
        } else {
            filteredCities = []
        }
    }

    func sendOtp(completion: @escaping (Bool, String?) -> Void) {
        guard !mobileNumber.isEmpty else { return }
        isLoading = true
        error = nil
        api.sendOtp(mobile: mobileNumber) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    self.isOtpSent = true
                    completion(true, response["message"])
                case .failure(let error):
                    self.error = error.localizedDescription
                    completion(false, error.localizedDescription)
                }
            }
        }
    }

    func register(details: [String: Any], completion: @escaping (Bool, String?) -> Void) {
        isLoading = true
        error = nil
        api.register(details: details) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    self.isOtpSent = true
                    completion(true, response["message"])
                case .failure(let error):
                    self.error = error.localizedDescription
                    completion(false, error.localizedDescription)
                }
            }
        }
    }

    func verifyOtp(completion: @escaping (Bool) -> Void) {
        guard otpCode.count == 6 else { return }
        isLoading = true
        api.verifyOtp(mobile: mobileNumber, otp: otpCode) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    self.isVerified = true
                    self.isProfileComplete = response.isProfileComplete ?? false
                    if let userData = try? JSONEncoder().encode(response) {
                        UserDefaults.standard.set(userData, forKey: "current_user")
                    }
                    completion(true)
                case .failure(let error):
                    self.error = error.localizedDescription
                    completion(false)
                }
            }
        }
    }

    func uploadProfileImage(image: UIImage, completion: @escaping (Bool) -> Void) {
        isLoading = true
        api.uploadImage(image: image) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let url):
                    self.profileImageUrl = url
                    completion(true)
                case .failure(let error):
                    self.error = error.localizedDescription
                    completion(false)
                }
            }
        }
    }

    func registerProfile(details: [String: Any], completion: @escaping (Bool) -> Void) {
        isLoading = true
        api.registerProfile(details: details) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    self.isProfileComplete = true
                    if let userData = try? JSONEncoder().encode(response) {
                        UserDefaults.standard.set(userData, forKey: "current_user")
                    }
                    completion(true)
                case .failure(let error):
                    self.error = error.localizedDescription
                    completion(false)
                }
            }
        }
    }

    func logout() {
        api.clearSession()
    }

    func checkUser(mobile: String, role: String? = nil, completion: @escaping (Bool, Bool) -> Void) {
        isLoading = true
        api.checkUser(mobile: mobile, role: role) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    completion(response.exists, response.isComplete)
                case .failure:
                    completion(false, false)
                }
            }
        }
    }
}
