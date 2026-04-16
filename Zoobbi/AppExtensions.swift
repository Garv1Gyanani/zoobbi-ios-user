import SwiftUI

extension Color {
    // Brand Colors matched from Android hex codes
    public static let darkGreen = Color(red: 14 / 255, green: 55 / 255, blue: 59 / 255)  // #0E373B
    static let brightGreen = Color(red: 198 / 255, green: 255 / 255, blue: 0 / 255)  // #C6FF00
    static let lightGreenBg = Color(red: 232 / 255, green: 241 / 255, blue: 236 / 255)  // #E8F1EC
    static let inputBgGray = Color(red: 245 / 255, green: 245 / 255, blue: 245 / 255)  // #F5F5F5
    static let textGrayColor = Color(red: 117 / 255, green: 117 / 255, blue: 117 / 255)  // #757575
    static let chipUnselectedBg = Color(red: 224 / 255, green: 228 / 255, blue: 229 / 255)  // #E0E4E5
    static let cardBgColor = Color.white // Matches Android Color.White
    static let appLoadingGreen = Color(red: 14 / 255, green: 55 / 255, blue: 59 / 255)  // Changed to darkGreen (#0E373B)

    // Legacy support for my previous edits
    static let appGreen = brightGreen
    static let appTeal = darkGreen
}

public struct AndroidCircularProgressViewStyle: ProgressViewStyle {
    public var tint: Color
    public var strokeWidth: CGFloat = 3
    
    @State private var isAnimating: Bool = false
    
    public init(tint: Color = .darkGreen, strokeWidth: CGFloat = 3) {
        self.tint = tint
        self.strokeWidth = strokeWidth
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        Circle()
            .trim(from: 0.2, to: 1.0)
            .stroke(tint, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
            .frame(width: 24, height: 24)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .onAppear {
                withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}
