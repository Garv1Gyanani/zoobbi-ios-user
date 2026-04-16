import SwiftUI

struct ForgotPasswordView: View {
    
    @State private var phone = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            Text("We’ll send you an OTP")
                .font(.title)
                .bold()
            
            Text("Quick verification to keep your account safe.")
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Phone No")
                HStack(spacing: 0) {
                    Text("+1 ")
                        .foregroundColor(.black)
                        .padding(.leading, 12)
                    TextField("Enter your Phone no", text: $phone)
                        .keyboardType(.phonePad)
                        .padding()
                }
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            
            Button {
                print("Send OTP tapped")
            } label: {
                Text("Send OTP")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.07, green: 0.23, blue: 0.21))
                    .foregroundColor(.green)
                    .cornerRadius(25)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Forgot Password")
        .navigationBarTitleDisplayMode(.inline)
    }
}
