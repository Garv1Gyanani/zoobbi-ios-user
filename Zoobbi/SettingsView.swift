import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var notificationsEnabled = true
    @State private var selectedLanguage = "English"

    var body: some View {
        VStack(spacing: 0) {

            // Header
            ZStack {
                HStack {
                    Button(action: { dismiss() }) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 236 / 255, green: 255 / 255, blue: 219 / 255))
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(
                                    Color(red: 27 / 255, green: 59 / 255, blue: 54 / 255))
                        }
                        .frame(width: 44, height: 44)
                    }
                    Spacer()
                }

                Text("Setting")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 32)

            VStack(spacing: 16) {
                // Notification Card
                HStack {
                    Text("Notification")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.black)

                    Spacer()

                    Toggle("", isOn: $notificationsEnabled)
                        .labelsHidden()
                        .tint(Color(red: 129 / 255, green: 228 / 255, blue: 104 / 255))  // #81E468
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(Color(red: 245 / 255, green: 245 / 255, blue: 245 / 255))
                .cornerRadius(12)

                // Language Card
                Button(action: {
                    // Language selection logic
                }) {
                    HStack {
                        Text(selectedLanguage)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.black)

                        Spacer()

                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(Color(red: 245 / 255, green: 245 / 255, blue: 245 / 255))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)

            Spacer()
        }
        .background(Color.white.ignoresSafeArea())
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
