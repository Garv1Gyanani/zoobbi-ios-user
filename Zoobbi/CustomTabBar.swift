import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let pillColor = Color(red: 0.9098, green: 0.9451, blue: 0.9255)  // #E8F1EC (Light Greenish)
    let activeColor = Color(red: 0.05, green: 0.22, blue: 0.23)  // Dark Teal

    var body: some View {
        HStack {
            Spacer()
            CustomTabBarItem(
                icon: "house.fill", title: "Home", isSelected: selectedTab == 0,
                pillColor: pillColor, activeColor: activeColor
            ) {
                selectedTab = 0
            }

            Spacer()

            CustomTabBarItem(
                icon: "qrcode.viewfinder", title: "Scan QR", isSelected: selectedTab == 1,
                pillColor: pillColor, activeColor: activeColor
            ) {
                selectedTab = 1
            }

            Spacer()

            CustomTabBarItem(
                icon: "person.fill", title: "Profile", isSelected: selectedTab == 2,
                pillColor: pillColor, activeColor: activeColor
            ) {
                selectedTab = 2
            }
            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: -5)
    }
}

struct CustomTabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let pillColor: Color
    let activeColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? activeColor : .gray)

                if isSelected {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(activeColor)
                } else {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, isSelected ? 16 : 10)
            .padding(.vertical, 8)
            .background(isSelected ? pillColor : Color.clear)
            .clipShape(Capsule())
        }
    }
}
