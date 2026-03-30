import SwiftUI


struct NearbyCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image("cafe") // add asset
                .resizable()
                .scaledToFill()
                .frame(width: 240, height: 140)
                .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Green Cafe")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                
                Text("Organic Coffee • 0.2 miles")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                HStack(spacing: 8) {
                    TagView(text: "Offer Available", backgroundColor: Color(red: 0.9, green: 0.95, blue: 0.94), textColor: Color(red: 0.07, green: 0.23, blue: 0.21))
                    TagView(text: "5 days left", backgroundColor: Color(.systemGray6), textColor: .gray)
                }
                .padding(.top, 4)
            }
            .padding(12)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .frame(width: 240)
        .padding(.bottom, 10)
    }
}

