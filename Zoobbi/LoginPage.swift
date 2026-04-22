import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @EnvironmentObject var appState: AppState
    @State private var navigateToOTP = false
    @State private var navigateToRegister = false
    @State private var validationError: String?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: 60)

                    // Logo
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .padding(.vertical, 24)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Good to See You Again")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)

                        Text("Log in to access to grab your favorite brand coupon")
                            .font(.system(size: 14))
                            .foregroundColor(.textGrayColor)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                    Spacer().frame(height: 32)

                    // Mobile Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mobile No")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)

                        HStack(spacing: 0) {
                            Text("+1 ")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.leading, 16)
                            TextField("Enter your 10 digit Mobile no", text: $viewModel.mobileNumber)
                                .keyboardType(.phonePad)
                                .padding(.vertical, 16)
                                .padding(.horizontal, 4)
                        }
                        .background(Color.inputBgGray)
                        .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        validationError != nil ? Color.red : Color.clear,
                                        lineWidth: 1)
                            )
                            .onChange(of: viewModel.mobileNumber) { newValue in
                                if newValue.count > 10 {
                                    viewModel.mobileNumber = String(newValue.prefix(10))
                                }
                                if newValue.count == 10 {
                                    validationError = nil
                                }
                            }

                        if let error = validationError {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.system(size: 12))
                                .padding(.leading, 4)
                        }
                    }
                    .padding(.horizontal, 24)

                    if let apiError = viewModel.error {
                        Text(apiError)
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                            .padding(.top, 8)
                    }

                    Spacer().frame(height: 24)

                    // Send OTP Button
                    Button(action: {
                        if viewModel.mobileNumber.count < 10 {
                            validationError = "Please enter a valid 10-digit mobile number"
                        } else {
                            viewModel.sendOtp { success, _ in
                                if success { navigateToOTP = true }
                            }
                        }
                    }) {
                        ZStack {
                            Text("Send OTP")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(
                                    Color(red: 198 / 255, green: 255 / 255, blue: 0 / 255)
                                )
                                .opacity(viewModel.isLoading ? 0 : 1)
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(
                                        AndroidCircularProgressViewStyle(
                                            tint: .appLoadingGreen))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color(red: 0.0549, green: 0.2157, blue: 0.2314))
                        .cornerRadius(28)
                    }
                    .padding(.horizontal, 24)
                    .disabled(viewModel.isLoading)
                    .background(
                        NavigationLink(
                            destination: OTPScreen(viewModel: viewModel), isActive: $navigateToOTP
                        ) {
                            EmptyView()
                        }
                    )

                    Spacer().frame(height: 24)

                    // Register Link
                    VStack(spacing: 16) {

                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .font(.system(size: 14))
                                .foregroundColor(.textGrayColor)
                            Button(action: { navigateToRegister = true }) {
                                Text("Register")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(
                        NavigationLink(
                            destination: RegisterStartPage(),
                            isActive: $navigateToRegister
                        ) {
                            EmptyView()
                        }
                    )

                    Spacer()
                }
            }
            .background(Color.white.ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct RegisterStartPage: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var navigateToOTP = false
    @State private var validationError: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: 40)

                // Back Button
                Button(action: {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 24))
                        .foregroundColor(.black)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .padding(.leading, 16)

                Spacer().frame(height: 24)

                Text("Create Account")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 24)

                Spacer().frame(height: 8)

                Text("Enter your mobile number to start matching deals.")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 117 / 255, green: 117 / 255, blue: 117 / 255))
                    .padding(.horizontal, 24)

                Spacer().frame(height: 32)

                // Mobile Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Mobile No")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)

                    HStack(spacing: 0) {
                        Text("+1 ")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.leading, 16)
                        TextField("Enter your 10 digit Mobile no", text: $viewModel.mobileNumber)
                            .keyboardType(.phonePad)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 4)
                    }
                    .background(Color(red: 245 / 255, green: 245 / 255, blue: 245 / 255))
                    .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    validationError != nil ? Color.red : Color.clear,
                                    lineWidth: 1)
                        )
                        .onChange(of: viewModel.mobileNumber) { newValue in
                            if newValue.count > 10 {
                                viewModel.mobileNumber = String(newValue.prefix(10))
                            }
                            if newValue.count == 10 {
                                validationError = nil
                            }
                        }

                    if let error = validationError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.system(size: 12))
                            .padding(.leading, 4)
                    }
                }
                .padding(.horizontal, 24)

                if let apiError = viewModel.error {
                    Text(apiError)
                        .foregroundColor(.red)
                        .font(.system(size: 14))
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                }

                Spacer().frame(height: 32)

                // Register Button
                Button {
                    if viewModel.mobileNumber.count < 10 {
                        validationError = "Please enter a valid 10-digit mobile number"
                    } else {
                        viewModel.checkUser(mobile: viewModel.mobileNumber, role: "user") { exists, isComplete in
                            if exists && isComplete {
                                validationError = "An account with this mobile already exists. Please Login."
                            } else {
                                viewModel.sendOtp { success, _ in
                                    if success {
                                        navigateToOTP = true
                                    }
                                }
                            }
                        }
                    }
                } label: {
                    ZStack {
                        Text("Register")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(red: 198 / 255, green: 255 / 255, blue: 0 / 255))
                            .opacity(viewModel.isLoading ? 0 : 1)
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(
                                    AndroidCircularProgressViewStyle(
                                        tint: .appLoadingGreen
                                    ))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color(red: 0.0549, green: 0.2157, blue: 0.2314))
                    .cornerRadius(28)
                }
                .padding(.horizontal, 24)
                .disabled(viewModel.isLoading)
                .background(
                    NavigationLink(
                        destination: OTPScreen(viewModel: viewModel),
                        isActive: $navigateToOTP
                    ) {
                        EmptyView()
                    }
                )

                Spacer()
            }
        }
        .navigationBarHidden(true)
        .background(Color.white.ignoresSafeArea())
    }
}
