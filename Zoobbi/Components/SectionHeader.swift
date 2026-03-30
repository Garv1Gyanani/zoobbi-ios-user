
import SwiftUI

struct SectionHeader: View {
    var title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
            
            Spacer()
            
            Button("See All") {
                print("See all tapped")
            }
            .foregroundColor(Color(red: 0.6, green: 0.89, blue: 0.49)) // Lime green
            .font(.system(size: 16, weight: .medium))
        }
    }
}
