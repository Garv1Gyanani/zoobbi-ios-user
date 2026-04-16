import SwiftUI
import Combine

struct OTPScreen: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: AuthViewModel
    @EnvironmentObject var appState: AppState
    @State private var otpDigits: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedField: Int?

    @State private var validationError: String? = nil
    @State private var navigateToRegister: Bool = false

    @State private var resendTimer: Int = 30
    @State private var canResend: Bool = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Navigation Links
            Group {
                // Home navigation handled via appState

                NavigationLink(
                    destination: RegisterScreen(viewModel: viewModel),
                    isActive: $navigateToRegister
                ) { EmptyView() }
            }
            .hidden()

            // Back Button
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 24))
                    .foregroundColor(.black)
            }
            .padding(.top, 40)
            .padding(.horizontal, 24)

            Spacer().frame(height: 24)

            Text("Verify with OTP")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 24)

            Spacer().frame(height: 8)

            Text("Sent to +1 \(viewModel.mobileNumber)")
                .font(.system(size: 14))
                .foregroundColor(.textGrayColor)
                .padding(.horizontal, 24)

            Spacer().frame(height: 32)

            // OTP Fields (6 boxes)
            HStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { index in
                    TextField("", text: $otpDigits[index])
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 20, weight: .bold))
                        .focused($focusedField, equals: index)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .background(Color.inputBgGray)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    validationError != nil ? Color.red : Color.clear, lineWidth: 1)
                        )
                        .onChange(of: otpDigits[index]) { newValue in
                            if newValue.count > 1 {
                                otpDigits[index] = String(newValue.last!)
                            }
                            viewModel.otpCode = otpDigits.joined()
                            if !newValue.isEmpty {
                                if index < 5 {
                                    focusedField = index + 1
                                } else {
                                    focusedField = nil
                                }
                                validationError = nil
                            }
                        }
                }
            }
            .padding(.horizontal, 24)

            if let error = validationError {
                Text(error)
                    .foregroundColor(.red)
                    .font(.system(size: 12))
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
            }

            if let apiError = viewModel.error {
                Text(apiError)
                    .foregroundColor(.red)
                    .font(.system(size: 14))
                    .padding(.top, 16)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            Spacer().frame(height: 32)

            // Verify Button
            Button(action: {
                if viewModel.otpCode.count < 6 {
                    validationError = "Please enter the 6-digit code"
                } else {
                    viewModel.verifyOtp { success in
                        if success {
                            if viewModel.isProfileComplete {
                                appState.isLoggedIn = true
                            } else {
                                navigateToRegister = true
                            }
                        }
                    }
                }
            }) {
                ZStack {
                    Text("Verify")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: 198 / 255, green: 255 / 255, blue: 0 / 255))
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
            .disabled(viewModel.isLoading)

            Spacer().frame(height: 24)

            HStack {
                Spacer()
                Text(canResend ? "Didn't receive the code? " : "Resend code in ")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Button(action: {
                    if canResend {
                        viewModel.sendOtp { success, message in
                            if success {
                                resendTimer = 30
                                canResend = false
                            }
                        }
                    }
                }) {
                    Text(canResend ? "Resend" : "\(resendTimer)s")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(canResend ? Color(red: 14 / 255, green: 55 / 255, blue: 59 / 255) : .gray)
                }
                .disabled(!canResend)
                Spacer()
            }
            .onReceive(timer) { _ in
                if resendTimer > 0 {
                    resendTimer -= 1
                } else {
                    canResend = true
                }
            }

            Spacer()
        }
        .navigationBarHidden(true)
        .background(Color.white.ignoresSafeArea())
        .onAppear { focusedField = 0 }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
