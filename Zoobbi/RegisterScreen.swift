import SwiftUI

struct RegisterScreen: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var birthDateValue: Date = Date()
    @State private var showDatePicker: Bool = false
    @State private var selectedGender: String = "Male"
    @State private var showImagePicker: Bool = false
    @State private var navigateToStep2: Bool = false

    private var birthDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: birthDateValue)
    }

    let genders = ["Male", "Female", "Other"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                headerSection

                formSection

                continueSection

                loginSection
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .background(Color.white.ignoresSafeArea())
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Back Button
            SwiftUI.Button(action: {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 24))
                    .foregroundColor(.black)
                    .padding(8)
                    .contentShape(Rectangle())
            }
            .padding(.top, 16)
            .padding(.leading, 16)

            Spacer()
                .frame(height: 32)

            // Title
            Text("Welcome to Zoobbi!")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 24)

            Spacer()
                .frame(height: 8)

            Text("Unlock exclusive coupons, daily deals, and smart savings.")
                .font(.system(size: 14))
                .foregroundColor(Color(red: 117 / 255, green: 117 / 255, blue: 117 / 255))
                .padding(.horizontal, 24)

            Spacer()
                .frame(height: 32)
        }
    }

    private var formSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Profile Image
            HStack {
                Spacer()
                SwiftUI.Button(action: { showImagePicker = true }) {
                    ZStack {
                        if let image = viewModel.profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.inputBgGray)
                                .frame(width: 100, height: 100)
                            Image(systemName: "camera.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 30))
                        }
                    }
                    .overlay(
                        Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
                Spacer()
            }
            .padding(.bottom, 10)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $viewModel.profileImage)
            }

            // Mobile Number
            VStack(alignment: .leading, spacing: 10) {
                Text("Mobile Number")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)

                TextField("Enter 10 digit Mobile no", text: $viewModel.mobileNumber)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .background(Color(red: 245 / 255, green: 245 / 255, blue: 245 / 255))
                    .cornerRadius(12)
                    .disabled(true)
                    .opacity(0.6)
            }

            // First Name
            VStack(alignment: .leading, spacing: 10) {
                Text("Your First Name")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(white: 0.15))

                TextField("Enter your first name", text: $firstName)
                    .font(.system(size: 15))
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .background(Color(red: 245 / 255, green: 245 / 255, blue: 245 / 255))
                    .cornerRadius(12)
            }

            // Last Name
            VStack(alignment: .leading, spacing: 10) {
                Text("Your Last Name")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(white: 0.15))

                TextField("Enter your last name", text: $lastName)
                    .font(.system(size: 15))
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .background(Color(red: 245 / 255, green: 245 / 255, blue: 245 / 255))
                    .cornerRadius(12)
            }

            // Birth Date
            VStack(alignment: .leading, spacing: 10) {
                Text("Your Birth date")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(white: 0.15))

                Button(action: {
                    showDatePicker = true
                }) {
                    HStack {
                        Text(birthDateString)
                            .font(.system(size: 15))
                            .foregroundColor(.black)

                        Spacer()

                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                            .font(.system(size: 18))
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .background(Color(red: 245 / 255, green: 245 / 255, blue: 245 / 255))
                    .cornerRadius(12)
                }
            }
            .sheet(isPresented: $showDatePicker) {
                VStack {
                    DatePicker(
                        "Select Birth Date", selection: $birthDateValue,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                    Button("Done") {
                        showDatePicker = false
                    }
                    .padding()
                }
                .presentationDetents([.medium])
            }

            // Gender
            VStack(alignment: .leading, spacing: 12) {
                Text("Gender")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)

                HStack(spacing: 12) {
                    ForEach(genders, id: \.self) { gender in
                        genderButton(gender)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }

    private func genderButton(_ gender: String) -> some View {
        SwiftUI.Button {
            selectedGender = gender
        } label: {
            Text(gender)
                .font(
                    .system(
                        size: 14,
                        weight: selectedGender == gender ? Font.Weight.bold : Font.Weight.regular)
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    selectedGender == gender
                        ? Color(red: 232 / 255, green: 245 / 255, blue: 233 / 255)
                        : Color(
                            red: 245 / 255, green: 245 / 255, blue: 245 / 255)
                )
                .foregroundColor(
                    selectedGender == gender
                        ? Color(red: 0, green: 61 / 255, blue: 43 / 255)
                        : Color(red: 117 / 255, green: 117 / 255, blue: 117 / 255)
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            selectedGender == gender
                                ? Color(red: 198 / 255, green: 255 / 255, blue: 0 / 255)
                                : Color.clear, lineWidth: 1
                        )
                )
        }
    }

    private var continueSection: some View {
        VStack {
            Spacer().frame(height: 40)

            NavigationLink(
                destination: SignupStep2Screen(
                    viewModel: viewModel,
                    firstName: firstName,
                    lastName: lastName,
                    birthDate: birthDateString,
                    gender: selectedGender,
                    mobileNumber: viewModel.mobileNumber
                ),
                isActive: $navigateToStep2
            ) {
                EmptyView()
            }
            .hidden()

            Button {
                navigateToStep2 = true
            } label: {
                Text("Continue")
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color(red: 0.0549, green: 0.2157, blue: 0.2314))
                    .foregroundColor(Color(red: 198 / 255, green: 255 / 255, blue: 0 / 255))
                    .cornerRadius(30)
            }
            .padding(.horizontal, 24)
        }
    }

    private var loginSection: some View {
        VStack {
            Spacer().frame(height: 32)

            HStack(spacing: 4) {
                Text("Already have an account?")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                Button {
                    dismiss()
                } label: {
                    Text("Login")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)

            Spacer().frame(height: 20)
        }
    }
}

struct RegisterScreen_Previews: PreviewProvider {
    static var previews: some View {
        RegisterScreen(viewModel: AuthViewModel())
    }
}
