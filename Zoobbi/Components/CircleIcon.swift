import SwiftUI

struct CircleIcon: View {
    var imageURL: String
    
    var body: some View {
        AsyncImage(url: URL(string: imageURL)) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            ProgressView()
        }
        .frame(width: 40, height: 40)
        .clipShape(Circle())
    }
}
