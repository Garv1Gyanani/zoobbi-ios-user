import SwiftUI

struct FilterDrawer: View {
    @Binding var isShowing: Bool
    @Binding var selectedFilter: String
    let dealTypes: [DealType]

    var body: some View {
        ZStack(alignment: .trailing) {
            if isShowing {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { isShowing = false }
                    }
            }
            if isShowing {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Filter")
                            .font(.headline)
                        Spacer()
                        Button("Cancel") {
                            withAnimation { isShowing = false }
                        }
                        .foregroundColor(Color(red: 14 / 255, green: 55 / 255, blue: 59 / 255))
                    }
                    .padding()

                    Divider()

                    ScrollView {
                        VStack(spacing: 0) {
                            filterRow(title: "All Deals", isSelected: selectedFilter == "All Deals")
                            ForEach(dealTypes, id: \._id) { type in
                                filterRow(title: type.name, isSelected: selectedFilter == type.name)
                            }
                        }
                    }
                    Spacer()
                }
                .frame(width: 300)
                .background(Color.white)
                .transition(.move(edge: .trailing))
            }
        }
    }

    private func filterRow(title: String, isSelected: Bool) -> some View {
        Button {
            selectedFilter = title
            withAnimation { isShowing = false }
        } label: {
            HStack {
                Circle()
                    .stroke(isSelected ? Color(red: 14 / 255, green: 55 / 255, blue: 59 / 255) : Color.gray, lineWidth: 2)
                    .frame(width: 20, height: 20)
                    .overlay(Circle().fill(isSelected ? Color(red: 14 / 255, green: 55 / 255, blue: 59 / 255) : Color.clear).padding(4))

                Text(title)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding()
        }
    }
}
