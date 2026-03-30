import SwiftUI

struct ContentView: View {
    
    @State private var phone = ""
    @State private var password = ""
    @State private var isPasswordHidden = true
    @State private var Gohome = false
    var body: some View {
        NavigationStack {
            ScrollView {
                
                
             
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Title
                    Text("Good to See You Again")
                        .font(.title)
                        .bold()
                    
                    Text("Log in to access to grab your favorite brand coupon")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    // Phone Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Phone No")
                            .font(.subheadline)
                        
                        HStack(spacing: 0) {
                            Text("+91 ")
                                .foregroundColor(.black)
                                .padding(.leading, 12)
                            TextField("Enter your Phone no", text: $phone)
                                .keyboardType(.phonePad)
                                .padding()
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Password")
                            .font(.subheadline)
                        
                        HStack {
                            if isPasswordHidden {
                                SecureField("Enter your Password", text: $password)
                            } else {
                                TextField("Enter your Password", text: $password)
                            }
                            
                            Button {
                                isPasswordHidden.toggle()
                            } label: {
                                Image(systemName: isPasswordHidden ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    // Forgot Password
                    HStack {
                        Spacer()
                        NavigationLink("Forgot Password?") {
                            ForgotPasswordView()
                        }
                        .font(.footnote)
                        .foregroundColor(.red)

                        .font(.footnote)
                        .foregroundColor(.red)
                    }
                    
                    // Login Button
                    Button {
                        print("Login tapped")
                        
                        Gohome = true
                    } label: {
                        Text("Login")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 0.07, green: 0.23, blue: 0.21))
                            .foregroundColor(.green)
                            .cornerRadius(25)
                    }
                    .padding(.top)
                    
                    // Divider OR
                    HStack {
                        Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                        Text("or")
                            .foregroundColor(.gray)
                        Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                    }
                    
                    // Google Button
                    SocialButton(icon: "globe", text: "Continue with Google")
                    
                    // Apple Button
                    SocialButton(icon: "applelogo", text: "Continue with Apple")
                    
                    Spacer(minLength: 40)
                    
                    // Terms
                    Text("By continuing, you agree to our Terms of Service and Privacy Policy.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            .navigationTitle("Login")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented : $Gohome){
                HomeView()
            }
        }
    }
}

struct SocialButton: View {
    var icon: String
    var text: String
    
    var body: some View {
        Button {
            print("\(text) tapped")
        } label: {
            HStack {
                Image(systemName: icon)
                Text(text)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            )
        }
    }
}
