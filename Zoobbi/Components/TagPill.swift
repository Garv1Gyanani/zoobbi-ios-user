import SwiftUI

// MARK: - Tag Pill
struct TagPill: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 15, weight: .medium))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color(red: 232 / 255, green: 236 / 255, blue: 238 / 255))  // #E8ECEE
            .foregroundColor(Color(red: 69 / 255, green: 90 / 255, blue: 100 / 255))  // #455A64
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
