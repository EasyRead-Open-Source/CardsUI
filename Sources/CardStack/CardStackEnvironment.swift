//
//  SwiftUIView.swift
//  CardsUI
//
//  Created by Phineas Guo on 2026/8/2.
//

import SwiftUI

struct CardIDPreferenceKey: PreferenceKey {
    
    static let defaultValue: Int? = nil

    static func reduce(value: inout Int?, nextValue: () -> Int?) {
        value = nextValue() ?? value
    }
}

extension View {
    /// Assigns a unique integer ID to this view so ``CardStack`` can identify
    /// and reorder it within the card pile.
    ///
    /// Every card inside a ``CardStack`` must carry this modifier with a stable
    /// ID. The stack uses these IDs internally to track which card is on top
    /// and to respond to the `currentCard` binding.
    ///
    /// ```swift
    /// CardStack(currentCard: $currentCard) {
    ///     ForEach(items) { item in
    ///         CardView(item: item)
    ///             .cardID(item.id)
    ///     }
    /// }
    /// ```
    public func cardID(_ id: Int) -> some View {
        preference(key: CardIDPreferenceKey.self, value: id)
    }
}
