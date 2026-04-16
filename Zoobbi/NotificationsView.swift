import SwiftUI

struct NotificationsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HomeViewModel

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

                Text("Notification")
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
            .padding(.bottom, 24)

            if let error = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    Text(error)
                        .foregroundColor(.black)
                        .font(.system(size: 14))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button(action: {
                        viewModel.fetchNotifications()
                    }) {
                        Text("Retry")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 120, height: 44)
                            .background(Color.darkGreen)
                            .cornerRadius(22)
                    }
                }
                .padding()
                Spacer()
            } else if viewModel.notifications.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "bell.slash")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("No notifications yet")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                    Text("Deals from businesses you follow will appear here.")
                        .font(.system(size: 13))
                        .foregroundColor(.gray.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                Spacer()
            } else {
                // Notifications List
                ScrollView {
                    VStack(spacing: 24) {
                        ForEach(viewModel.notifications) { note in
                            HStack(alignment: .top, spacing: 16) {

                                // Business Logo or Placeholder
                                CachedAsyncImage(url: URL(string: formatUrl(note.business?.logo))) {
                                    ZStack {
                                        Circle().fill(Color.gray.opacity(0.1))
                                        ProgressView()
                                    }
                                }
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(
                                            note.type == "new_deal"
                                                ? (note.deal?.title ?? "New Deal")
                                                : (note.business?.businessName ?? "Zoobbi")
                                        )
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))

                                        Spacer()

                                        Text(timeAgo(note.createdAt))
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                    }

                                    Text(note.message)
                                        .font(.system(size: 13))
                                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                                        .lineSpacing(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.markNotificationRead(id: note._id)
                                // Handle navigation if needed
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                note.isRead == false ? Color.green.opacity(0.05) : Color.clear
                            )
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 12)
                }
            }

            Spacer()
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            viewModel.fetchNotifications()
        }
    }

    private func formatUrl(_ path: String?) -> String {
        guard let path = path, !path.isEmpty else { return "" }
        if path.hasPrefix("http") { return path }
        let baseUrl = "https://zoobbi.com"
        let fullPath = path.hasPrefix("/") ? path : "/\(path)"
        return baseUrl + fullPath
    }

    private func timeAgo(_ dateStr: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        var date = formatter.date(from: dateStr)

        if date == nil {
            // Fallback for non-fractional
            formatter.formatOptions = [.withInternetDateTime]
            date = formatter.date(from: dateStr)
        }

        guard let finalDate = date else { return "now" }

        let now = Date()
        let diff = now.timeIntervalSince(finalDate)

        let minutes = Int(diff) / 60
        let hours = minutes / 60
        let days = hours / 24

        if days > 0 { return "\(days)d ago" }
        if hours > 0 { return "\(hours)h ago" }
        if minutes > 0 { return "\(minutes)m ago" }
        return "now"
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView(viewModel: HomeViewModel())
    }
}
