//
//  SwiftUIView.swift
//  CardsUI
//
//  Created by Phineas Guo on 2026/8/2.
//

import SwiftUI

public struct CardStack<Content: View>: View {
    @Binding var currentCard: Int
    let content: Content
    let threshold: CGFloat

    @State private var cardOrder: [Int] = []
    @State private var idToIndex: [Int: Int] = [:]
    @State private var isReady = false

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
            ZStack {
                ForEach(Array(subviews.indices), id: \.self) { idx in
                    subviews[idx]
                        .opacity(0)
                        .allowsHitTesting(false)
                        .onPreferenceChange(CardIDPreferenceKey.self) { id in
                            guard let id else { return }
                            idToIndex[id] = idx
                            tryReady()
                        }
                }

                if isReady {
                    ForEach(cardOrder, id: \.self) { cardID in
                        if let idx = idToIndex[cardID], idx < subviews.count {
                            let isTop = cardOrder.first == cardID
                            subviews[idx]
                                .modifier(CardDragModifier(
                                    isTop: isTop,
                                    baseZIndex: Double(cardOrder.count - (cardOrder.firstIndex(of: cardID) ?? 0)) + 100,
                                    threshold: threshold,
                                    onSwipedAway: { moveTopToBottom() }
                                ))
                                .offset(stackOffset(for: cardID))
                                .rotationEffect(stackRotation(for: cardID))
                        }
                    }
                }
            }
        }
        .onChange(of: currentCard) { _, newID in
            bringToTop(newID)
        }
    }

    private func tryReady() {
        guard !isReady else { return }
        guard idToIndex.count == contentSubviewsCount else { return }
        isReady = true
        cardOrder = idToIndex.sorted { $0.value < $1.value }.map(\.key)
        bringToTop(currentCard)
    }
    
    private var contentSubviewsCount: Int {
        (idToIndex.values.max() ?? -1) + 1
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
        guard let idx = cardOrder.firstIndex(of: id), idx != 0 else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            cardOrder.remove(at: idx)
            cardOrder.insert(id, at: 0)
        }
    }

    private func updateCurrentCard() {
        guard !cardOrder.isEmpty else { return }
        currentCard = cardOrder[0]
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
