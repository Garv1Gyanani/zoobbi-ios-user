import SwiftUI

// MARK: - Burger Illustration
struct BurgerIllustration: View {
    var body: some View {
        VStack(spacing: 0) {
            Group {
                Ellipse()
                    .fill(Color(red: 0.75, green: 0.45, blue: 0.2))
                    .frame(width: 180, height: 60)
                    .shadow(color: .black.opacity(0.3), radius: 4, y: 3)
                Rectangle()
                    .fill(Color(red: 0.9, green: 0.6, blue: 0.2).opacity(0.85))
                    .frame(width: 170, height: 12)
                Ellipse()
                    .fill(Color(red: 0.35, green: 0.2, blue: 0.1))
                    .frame(width: 175, height: 22)
                Rectangle()
                    .fill(Color(red: 0.98, green: 0.78, blue: 0.2))
                    .frame(width: 175, height: 10)
                Ellipse()
                    .fill(Color(red: 0.85, green: 0.25, blue: 0.25))
                    .frame(width: 170, height: 14)
                Ellipse()
                    .fill(Color(red: 0.3, green: 0.65, blue: 0.3))
                    .frame(width: 185, height: 18)
                Ellipse()
                    .fill(Color(red: 0.82, green: 0.6, blue: 0.3))
                    .frame(width: 180, height: 35)
            }
        }
    }
}
