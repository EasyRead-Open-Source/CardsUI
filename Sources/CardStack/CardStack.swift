//
//  SwiftUIView.swift
//  CardsUI
//
//  Created by Phineas Guo on 2026/8/2.
//

import SwiftUI

/// A swipeable card stack that lets users drag the top card to dismiss it,
/// revealing the next card underneath.
///
/// `CardStack` turns any collection of views into an interactive pile of cards
/// similar to Tinder's card deck. Each view receives a unique ID via the
/// ``cardID(_:)`` modifier so the stack can track and reorder cards
/// individually.
///
/// ```swift
/// @State private var currentCard = 0
///
/// CardStack(currentCard: $currentCard) {
///     ForEach(0..<10) { i in
///         Text("Card \(i)")
///             .cardID(i)
///     }
/// }
/// ```
///
/// - Top card is draggable in any direction; releasing past `threshold`
///   sends it to the bottom of the stack.
/// - Cards beneath the top card are stacked with a slight vertical offset and
///   a subtle rotation.
/// - You can programmatically jump to any card by changing the `currentCard`
///   binding.
///
/// > Important: Every card must have a unique, stable ID set with ``cardID(_:)``.
///   The stack will not render until all cards have reported their IDs.
public struct CardStack<Content: View>: View {
    /// The ID of the card currently at the top of the stack.
    ///
    /// Write to this binding to programmatically bring a card to the top.
    /// It is updated automatically after a swipe dismisses the top card.
    @Binding var currentCard: Int

    let content: Content

    /// The minimum drag distance (in points) required to trigger a swipe-away.
    /// Defaults to 100.
    let threshold: CGFloat

    @State private var cardOrder: [Int] = []
    @State private var sensoryTrigger = false

    /// Creates a card stack.
    ///
    /// - Parameters:
    ///   - currentCard: A binding to the ID of the card to show on top.
    ///   - threshold: Minimum drag distance to trigger a swipe. Defaults to 100.
    ///   - content: A `@ViewBuilder` that produces the card views. Each card
    ///     must carry a ``cardID(_:)`` modifier with a unique, stable integer ID.
    public init(
        currentCard: Binding<Int>,
        threshold: CGFloat = 100,
        @ViewBuilder content: () -> Content
    ) {
        self._currentCard = currentCard
        self.threshold = threshold
        self.content = content()
    }

    public var body: some View {
        Group(subviews: content) { subviews in
            let reportedCardIDs = subviews.map { $0.containerValues.cardStackID }
            let idToIndex = subviews.indices.reduce(into: [Int: Int]()) { result, index in
                if let cardID = subviews[index].containerValues.cardStackID {
                    result[cardID] = index
                }
            }

            ZStack {
                ForEach(cardOrder, id: \.self) { cardID in
                    if let idx = idToIndex[cardID], idx < subviews.count {
                        let isTop = cardOrder.first == cardID
                        subviews[idx]
                            .modifier(CardDragModifier(
                                isTop: isTop,
                                baseZIndex: Double(cardOrder.count - (cardOrder.firstIndex(of: cardID) ?? 0)) + 100,
                                threshold: threshold,
                                onSwipedAway: {
                                    moveTopToBottom()
                                    sensoryTrigger.toggle()
                                }
                            ))
                            .offset(stackOffset(for: cardID))
                            .rotationEffect(stackRotation(for: cardID))
                    }
                }
            }
            .onChange(of: reportedCardIDs, initial: true) { _, cardIDs in
                synchronizeCardOrder(with: cardIDs)
            }
        }
        .sensoryFeedback(.success, trigger: sensoryTrigger)
        .onChange(of: currentCard) { _, newID in
            bringToTop(newID)
        }
    }

    private func synchronizeCardOrder(with reportedCardIDs: [Int?]) {
        guard let snapshot = CardStackOrder(reportedCardIDs: reportedCardIDs) else {
            if !cardOrder.isEmpty {
                cardOrder = []
            }
            return
        }

        let nextOrder = snapshot.reconciling(
            existingOrder: cardOrder,
            currentCard: currentCard
        )
        if cardOrder != nextOrder {
            cardOrder = nextOrder
        }
        if let topCard = nextOrder.first, !nextOrder.contains(currentCard) {
            currentCard = topCard
        }
    }

    private func moveTopToBottom() {
        guard !cardOrder.isEmpty else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            let top = cardOrder.removeFirst()
            cardOrder.append(top)
            updateCurrentCard()
        }
    }

    private func bringToTop(_ id: Int) {
        guard let idx = cardOrder.firstIndex(of: id) else {
            updateCurrentCard()
            return
        }
        guard idx != 0 else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            cardOrder.remove(at: idx)
            cardOrder.insert(id, at: 0)
        }
    }

    private func updateCurrentCard() {
        guard let topCard = cardOrder.first, currentCard != topCard else { return }
        currentCard = topCard
    }

    private func stackOffset(for cardID: Int) -> CGSize {
        guard let pos = cardOrder.firstIndex(of: cardID), pos > 0 else { return .zero }
        return CGSize(width: 0, height: CGFloat(pos) * 8)
    }

    private func stackRotation(for cardID: Int) -> Angle {
        guard let pos = cardOrder.firstIndex(of: cardID), pos > 0 else { return .zero }
        return .degrees(Double((cardID % 5) - 2) * 1.5)
    }
}

struct CardStackOrder: Equatable {
    let cardIDs: [Int]

    init?(reportedCardIDs: [Int?]) {
        let cardIDs = reportedCardIDs.compactMap { $0 }
        guard cardIDs.count == reportedCardIDs.count,
              Set(cardIDs).count == cardIDs.count
        else { return nil }
        self.cardIDs = cardIDs
    }

    func reconciling(existingOrder: [Int], currentCard: Int) -> [Int] {
        let validCardIDs = Set(cardIDs)
        var reconciledOrder = existingOrder.filter { validCardIDs.contains($0) }
        var knownCardIDs = Set(reconciledOrder)
        for cardID in cardIDs where knownCardIDs.insert(cardID).inserted {
            reconciledOrder.append(cardID)
        }

        guard let index = reconciledOrder.firstIndex(of: currentCard), index > 0 else {
            return reconciledOrder
        }

        let selectedCardID = reconciledOrder.remove(at: index)
        reconciledOrder.insert(selectedCardID, at: 0)
        return reconciledOrder
    }
}
