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
    public func cardID(_ id: Int) -> some View {
        preference(key: CardIDPreferenceKey.self, value: id)
    }
}
