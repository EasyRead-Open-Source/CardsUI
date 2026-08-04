import SwiftUI

struct CardStackDemo: View {
    @State private var currentCard: Int = 0

    private let colors: [Color] = [.brown, .gray, .orange, .mint, .indigo]

    var body: some View {
        VStack(spacing: 0) {
            Text("Current card: Card \(currentCard)")
                .font(.headline)
                .padding(.top)

            CardStack(currentCard: $currentCard) {
                ForEach(Array(colors.enumerated()), id: \.offset) { idx, color in
                    Text("Card \(idx)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(color, in: .rect(cornerRadius: 24))
                        .shadow(radius: 4)
                        .cardID(idx)
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 24)

            Button("Jump to Card 0") {
                currentCard = 0
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    CardStackDemo()
}
