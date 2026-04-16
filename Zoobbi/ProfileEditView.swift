import SwiftUI
import UIKit

struct ProfileEditView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState

    @StateObject private var authViewModel = AuthViewModel()
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var mobileNo: String = ""

    var body: some View {
        VStack(spacing: 0) {

            // Custom Navigation Bar
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.9, green: 0.98, blue: 0.85))  // Light green background
                            .frame(width: 44, height: 44)
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18))
                            .foregroundColor(Color(red: 0.15, green: 0.4, blue: 0.25))  // Dark green arrow
                    }
                }

                Spacer()

                Text("Profile edit")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)

                Spacer()

                // Invisible placeholder to keep title centered
                Circle()
                    .fill(Color.clear)
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 16)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // Profile Image Selection
                    Button(action: {
                        showImagePicker = true
                    }) {
                        ZStack(alignment: .bottomTrailing) {
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else if let imageUrl = appState.currentUser?.profileImage,
                                let url = URL(string: APIService.shared.rootURL + imageUrl)
                            {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                    default:
                                        Circle()
                                            .fill(Color(red: 0.95, green: 0.95, blue: 0.95))
                                            .frame(width: 100, height: 100)
                                    }
                                }
                            } else {
                                Circle()
                                    .fill(Color(red: 0.95, green: 0.95, blue: 0.95))
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 40))
                                    )
                            }

                            // Camera Icon Overlay
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.15, green: 0.4, blue: 0.25))  // Dark Green
                                    .frame(width: 30, height: 30)
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14))
                            }
                        }
                    }
                    .padding(.top, 10)

                    // Input Fields
                    VStack(spacing: 24) {

                        // Name Field
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Enter Name")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))

                            TextField("Enter Name", text: $name)
                                .padding()
                                .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                                .cornerRadius(12)
                        }

                        // Email Field
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Enter Email")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))

                            TextField("Enter Email", text: $email)
                                .keyboardType(.emailAddress)
                                #if os(iOS)
                                    .textInputAutocapitalization(.never)
                                #endif
                                .padding()
                                .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                                .cornerRadius(12)
                        }

                        // Mobile Number Field
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Enter Mobile No")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))

                            HStack(spacing: 8) {
                                Text("+1 ")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)

                                TextField("XXX XXX XXXX", text: $mobileNo)
                                    .keyboardType(.phonePad)
                            }
                            .padding()
                            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                            .cornerRadius(12)
                        }

                    }
                    .padding(.horizontal, 24)

                    if let error = authViewModel.error {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                            .padding(.horizontal, 24)
                    }

                    Spacer()
                        .frame(height: 32)

                    // Update Profile Button
                    Button(action: {
                        updateProfile()
                    }) {
                        ZStack {
                            Text("Update Profile")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(red: 0.45, green: 0.85, blue: 0.15))
                                .opacity(authViewModel.isLoading ? 0 : 1)

                            if authViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(AndroidCircularProgressViewStyle(tint: .white))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.black)
                        .cornerRadius(24)
                    }
                    .padding(.horizontal, 24)
                    .disabled(authViewModel.isLoading)

                    Spacer()
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .onAppear {
            if let user = appState.currentUser {
                name = user.name ?? ""
                email = user.email ?? ""
                mobileNo = user.mobile ?? ""
            }
        }
    }

    private func updateProfile() {
        var details = [
            "name": name,
            "email": email,
            "mobile": mobileNo,
        ]

        if let image = selectedImage {
            authViewModel.isLoading = true
            authViewModel.uploadProfileImage(image: image) { success in
                if success {
                    details["profileImage"] = authViewModel.profileImageUrl
                    authViewModel.registerProfile(details: details) { success in
                        if success {
                            appState.loadCurrentUser()
                            dismiss()
                        }
                    }
                } else {
                    authViewModel.isLoading = false
                }
            }
        } else {
            // Include existing image URL if not changed
            if let existingUrl = appState.currentUser?.profileImage {
                details["profileImage"] = existingUrl
            }

            authViewModel.registerProfile(details: details) { success in
                if success {
                    appState.loadCurrentUser()
                    dismiss()
                }
            }
        }
    }

}

struct ProfileEditView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileEditView()
    }
}
