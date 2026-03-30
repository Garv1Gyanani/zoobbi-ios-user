import SwiftUI


struct TagView: View {
    var text: String
    var backgroundColor: Color = Color(.systemGray5)
    var textColor: Color = .gray
    
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundColor(textColor)
            .background(backgroundColor)
            .cornerRadius(8) // More like the image (rounded rectangle)
    }
}
