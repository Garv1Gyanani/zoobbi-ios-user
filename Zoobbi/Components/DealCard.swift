import SwiftUI
import UIKit

// MARK: - Deal Card
struct DealCard: View {
    @Environment(\.openURL) var openURL
    let deal: Deal
    let isFavorite: Bool
    let distance: String
    var onCardTap: (() -> Void)? = nil
    var onFavoriteTap: (() -> Void)? = nil
    var onEllipsisTap: (() -> Void)? = nil
    var onCallTap: (() -> Void)? = nil
    var onNavigateTap: (() -> Void)? = nil

    private let baseUrl = "https://zoobbi.com"

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                // 1. Header Row (Logo, Name, Actions)
                HStack(spacing: 12) {
                    // Clickable area for Logo and Name/Distance
                    HStack(spacing: 12) {
                        // Avatar/Logo
                        CachedAsyncImage(url: URL(string: formatUrl(deal.business?.logo))) {
                            ZStack {
                                Circle()
                                    .fill(logoPlaceholderColor)
                                Text(deal.business?.businessName?.prefix(1).uppercased() ?? "B")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())

                        // Name and Distance
                        VStack(alignment: .leading, spacing: 2) {
                            Text(deal.business?.businessName ?? "Store")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                            Text(deal.type == "online" ? "Online Deal" : distance)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onCardTap?()
                    }

                    Spacer()

                    // Actions (Heart, More)
                    HStack(spacing: 16) {
                        Button(action: { onFavoriteTap?() }) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 20))
                                .foregroundColor(isFavorite ? .red : .gray)
                        }
                        .buttonStyle(BorderlessButtonStyle())

                        Button(action: { onEllipsisTap?() }) {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                                .rotationEffect(.degrees(90))
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                .padding(.top, 12)
                .padding(.horizontal, 12)

                Spacer().frame(height: 6)
                Divider()
                    .background(Color(red: 238 / 255, green: 238 / 255, blue: 238 / 255))
                Spacer().frame(height: 10)

                // 2. Title and Description
                VStack(alignment: .leading, spacing: 6) {
                    Text(dealTitle)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.black)

                    if let desc = deal.description, !desc.isEmpty {
                        Text(desc)
                            .font(.system(size: 15))
                            .foregroundColor(
                                Color(red: 102 / 255, green: 102 / 255, blue: 102 / 255)
                            )
                            .lineSpacing(2)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
                .contentShape(Rectangle())

                // 3. Main Image Container
                ZStack(alignment: .topTrailing) {
                    Color(red: 245 / 255, green: 245 / 255, blue: 247 / 255)

                    CachedAsyncImage(url: URL(string: formatUrl(deal.image))) {
                        ProgressView()
                    }
                    .scaledToFill()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 280)

                    Text("1/1")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.4))
                        .clipShape(Capsule())
                        .padding(12)
                }
                .frame(height: 280)
                .frame(maxWidth: .infinity)
                .cornerRadius(12)
                .padding(.horizontal, 12)
                .clipped()
                .contentShape(Rectangle())
            }
            .contentShape(Rectangle())

            Spacer().frame(height: 14)

            // 4. Footer (Pills and Action Buttons)
            HStack(spacing: 12) {
                HStack(spacing: 10) {
                    TagPill(text: daysLeftText)
                    TagPill(text: dealPillText)
                }

                Spacer()

                HStack(spacing: 12) {
                    // Call Button
                    Button(action: {
                        UISelectionFeedbackGenerator().selectionChanged()
                        onCallTap?()
                        if let phone = deal.business?.phone {
                            let sanitized = phone.filter { $0.isNumber }
                            if let url = URL(string: "telprompt://\(sanitized)")
                                ?? URL(string: "tel://\(sanitized)")
                            {
                                UIApplication.shared.open(url)
                            }
                        }
                    }) {
                        Image("ic_call_custom")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .foregroundColor(.white)
                            .padding(10)
                            .frame(width: 38, height: 38)
                            .background(Color(red: 14 / 255, green: 55 / 255, blue: 59 / 255))
                            .clipShape(Circle())
                    }
                    .buttonStyle(BorderlessButtonStyle())

                    // Navigate Button
                    let isOnline = deal.type == "online"
                    Button(action: {
                        UISelectionFeedbackGenerator().selectionChanged()
                        onNavigateTap?()
                        if isOnline {
                            if let link = deal.link,
                                let url = URL(
                                    string: link.hasPrefix("http") ? link : "https://\(link)")
                            {
                                UIApplication.shared.open(url)
                            }
                        } else if let loc = deal.business?.location, let coords = loc.coordinates,
                            coords.count >= 2
                        {
                            let urlString =
                                "http://maps.apple.com/?daddr=\(coords[1]),\(coords[0])"
                            if let url = URL(string: urlString) {
                                UIApplication.shared.open(url)
                            }
                        } else if let address = deal.business?.formattedAddress, !address.isEmpty {
                            let urlString =
                                "http://maps.apple.com/?daddr=\(address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                            if let url = URL(string: urlString) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }) {
                        Image(isOnline ? "ic_web_custom" : "ic_direction_custom")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .foregroundColor(.white)
                            .padding(10)
                            .frame(width: 38, height: 38)
                            .background(Color(red: 14 / 255, green: 55 / 255, blue: 59 / 255))
                            .clipShape(Circle())
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    private var logoPlaceholderColor: Color {
        let name = deal.business?.businessName ?? ""
        return name.count % 2 == 0
            ? Color(red: 244 / 255, green: 67 / 255, blue: 54 / 255)
            : Color(red: 25 / 255, green: 118 / 255, blue: 210 / 255)
    }

    private var dealTitle: String {
        if let title = deal.title, !title.isEmpty {
            return title
        }
        if let offerType = deal.offerType, !offerType.isEmpty {
            return offerType
        }
        if let value = deal.value {
            return deal.dealType == "discount" ? "\(value)%" : "$\(value)"
        }
        return "Special Offer"
    }

    private var daysLeftText: String {
        guard let endDate = deal.endDate else { return "Active" }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = formatter.date(from: endDate) {
            let now = Date()
            let diff = date.timeIntervalSince(now)

            if diff <= 0 {
                return "Expired"
            }

            let hours = Int(diff) / 3600
            if hours >= 24 {
                let days = hours / 24
                return "\(days) days left"
            } else if hours >= 1 {
                return "\(hours) hours left"
            } else {
                let minutes = Int(diff) / 60
                if minutes >= 1 {
                    return "\(minutes) mins left"
                } else {
                    return "Ends soon"
                }
            }
        }
        return "Active"
    }

    private var dealPillText: String {
        if deal.dealType == "discount", let value = deal.value {
            return "\(value)%"
        }
        if deal.dealType == "price", let value = deal.value {
            return "$\(value)"
        }
        return deal.category ?? "Deal"
    }

    private func formatUrl(_ path: String?) -> String {
        guard let path = path, !path.isEmpty else { return "" }
        if path.hasPrefix("http") { return path }
        if path.hasPrefix("/") { return baseUrl + path }
        return baseUrl + "/" + path
    }
}
