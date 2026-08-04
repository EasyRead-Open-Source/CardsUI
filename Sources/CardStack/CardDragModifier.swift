//
//  SwiftUIView.swift
//  CardsUI
//
//  Created by Phineas Guo on 2026/8/2.
//

import SwiftUI

struct CardDragModifier: ViewModifier {
    let isTop: Bool
    let baseZIndex: Double
    let threshold: CGFloat
    let onSwipedAway: () -> Void

    @State private var offset: CGSize = .zero
    @State private var isAnimating = false
    @State private var isBehind = false

    func body(content: Content) -> some View {
        content
            .offset(offset)
            .rotationEffect(isAnimating ? .degrees(offset.width / 12) : .zero)
            .zIndex(isBehind ? 0 : baseZIndex)
            .contentShape(.rect)
            .gesture((isTop && !isAnimating) ? dragGesture : nil)
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = value.translation
            }
            .onEnded { value in
                let d = value.translation.distance()
                guard d > threshold else {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        offset = .zero
                    }
                    return
                }

                isAnimating = true
                let fly = CGSize(
                    width: value.translation.width * 2.5,
                    height: value.translation.height * 2.5
                )

                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    offset = fly
                }

                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(0.30))
                    isBehind = true
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                        offset = .zero
                    }
                }

                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(0.75))
                    offset = .zero
                    isAnimating = false
                    isBehind = false
                    onSwipedAway()
                }
            }
    }
}

private extension CGSize {
    func distance() -> CGFloat {
        sqrt(width * width + height * height)
    }
}
