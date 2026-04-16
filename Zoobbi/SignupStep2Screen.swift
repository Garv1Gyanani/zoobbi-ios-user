import SwiftUI

struct SignupStep2Screen: View {
    @ObservedObject var viewModel: AuthViewModel
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    // Previous step data
    var firstName: String
    var lastName: String
    var birthDate: String
    var gender: String
    var mobileNumber: String

    @State private var email: String = ""
    @State private var selectedState: String = ""
    @State private var selectedCity: String = ""
    @State private var navigateToOTP: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Back Button
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 24))
                    .foregroundColor(.black)
            }
            .padding(.top, 16)
            .padding(.horizontal, 24)

            Spacer()
                .frame(height: 32)

            // Title
            Text("Almost There!")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 24)

            Spacer()
                .frame(height: 12)

            // Subtitle
            Text("Just a few details to personalize your Zoobbi experience.")
                .font(.system(size: 14))
                .foregroundColor(Color.textGrayColor)
                .padding(.horizontal, 24)

            Spacer()
                .frame(height: 32)

            // Fields Form
            VStack(alignment: .leading, spacing: 20) {
                // Email
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your Email Address")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)

                    TextField("Enter your email address", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .font(.system(size: 14))
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        .background(Color.inputBgGray)
                        .cornerRadius(12)
                }

                // State
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your State")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(white: 0.15))

                    Menu {
                        if viewModel.states.isEmpty {
                            Text("No states available")
                        } else {
                            ForEach(viewModel.states) { state in
                                Button(state.name) {
                                    selectedState = state.name
                                    selectedCity = ""
                                    viewModel.filterCities(stateName: state.name)
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedState.isEmpty ? "Select your state" : selectedState)
                                .font(.system(size: 15))
                                .foregroundColor(selectedState.isEmpty ? .gray : .primary)

                            Spacer()

                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        .background(Color(red: 245 / 255, green: 245 / 255, blue: 245 / 255))
                        .cornerRadius(12)
                    }
                }

                // City
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your City")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(white: 0.15))

                    Menu {
                        if selectedState.isEmpty {
                            Text("Select state first")
                        } else if viewModel.filteredCities.isEmpty {
                            Text("No cities available")
                        } else {
                            ForEach(viewModel.filteredCities) { city in
                                Button(city.name) {
                                    selectedCity = city.name
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(
                                selectedCity.isEmpty
                                    ? (selectedState.isEmpty
                                        ? "Select state first" : "Select your city") : selectedCity
                            )
                            .font(.system(size: 15))
                            .foregroundColor(selectedCity.isEmpty ? .gray : .primary)

                            Spacer()

                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        .background(Color(red: 245 / 255, green: 245 / 255, blue: 245 / 255))
                        .cornerRadius(12)
                    }
                    .disabled(selectedState.isEmpty)
                }
            }
            .padding(.horizontal, 24)

            if let error = viewModel.error {
                Text(error)
                    .foregroundColor(.red)
                    .font(.system(size: 14))
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
            }

            Spacer()
                .frame(height: 40)

            NavigationLink(
                destination: OTPScreen(viewModel: viewModel),
                isActive: $navigateToOTP
            ) { EmptyView() }
            .hidden()

            // Confirm Button
            Button(action: {
                var details: [String: Any] = [
                    "firstName": firstName,
                    "lastName": lastName,
                    "name": "\(firstName) \(lastName)",
                    "dob": birthDate,
                    "gender": gender,
                    "email": email,
                    "state": selectedState,
                    "city": selectedCity,
                    "mobile": mobileNumber,
                ]

                if viewModel.isVerified {
                    // Already have a token and verified, just update the profile
                    if let image = viewModel.profileImage {
                        viewModel.uploadProfileImage(image: image) { success in
                            if success {
                                var updatedDetails = details
                                updatedDetails["profileImage"] = viewModel.profileImageUrl
                                viewModel.registerProfile(details: updatedDetails) { success in
                                    if success {
                                        appState.isLoggedIn = true
                                    }
                                }
                            }
                        }
                    } else {
                        viewModel.registerProfile(details: details) { success in
                            if success {
                                appState.isLoggedIn = true
                            }
                        }
                    }
                } else {
                    // New registration flow, needs OTP
                    if let image = viewModel.profileImage {
                        viewModel.uploadProfileImage(image: image) { success in
                            if success {
                                var updatedDetails = details
                                updatedDetails["profileImage"] = viewModel.profileImageUrl
                                viewModel.register(details: updatedDetails) { success, _ in
                                    if success { navigateToOTP = true }
                                }
                            }
                        }
                    } else {
                        viewModel.register(details: details) { success, _ in
                            if success { navigateToOTP = true }
                        }
                    }
                }
            }) {
                ZStack {
                    Text("Confirm")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: 198 / 255, green: 255 / 255, blue: 0 / 255))
                        .opacity(viewModel.isLoading ? 0 : 1)
                    if viewModel.isLoading {
                        ProgressView().progressViewStyle(
                            AndroidCircularProgressViewStyle(
                                tint: .appLoadingGreen))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color(red: 0.0549, green: 0.2157, blue: 0.2314))
                .cornerRadius(30)
            }
            .padding(.horizontal, 24)
            .disabled(viewModel.isLoading)

            Spacer()
        }
        .navigationBarHidden(true)
        .background(Color.white.ignoresSafeArea())
    }
}

struct SignupStep2Screen_Previews: PreviewProvider {
    static var previews: some View {
        SignupStep2Screen(
            viewModel: AuthViewModel(), firstName: "", lastName: "", birthDate: "", gender: "",
            mobileNumber: "1234567890")
    }
}
