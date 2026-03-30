import SwiftUI

// MARK: - Tab Bar Item
struct TabBarItem: View {
    let icon: String
    let label: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: selected ? .bold : .medium))
                    .foregroundColor(selected ? .darkGreen : .gray)

                if selected {
                    Text(label)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.darkGreen)
                } else {
                    Text(label)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(selected ? Color.lightGreenBg : Color.clear)
            .clipShape(Capsule())
            .frame(maxWidth: .infinity)
        }
    }
}
