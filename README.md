# CardsUI

A lightweight SwiftUI component that turns any collection of views into an interactive, swipeable card stack.

## Platforms

- iOS 18+
- macOS 15+
- watchOS 11+
- tvOS 18+
- visionOS 2+

## Installation

Add CardsUI as a Swift Package Manager dependency:

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/guoPhineas/CardsUI/", branch: "main"),
]
```

Or in Xcode: **File → Add Package Dependencies…** and paste the repository URL.

## Usage

```swift
import CardsUI
import SwiftUI

struct ContentView: View {
    @State private var currentCard = 0

    var body: some View {
        CardStack(currentCard: $currentCard) {
            ForEach(0..<10) { i in
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(hue: Double(i) / 10, saturation: 0.7, brightness: 0.9))
                    .overlay {
                        Text("Card \(i)")
                            .font(.largeTitle)
                            .foregroundStyle(.white)
                    }
                    .cardID(i)
            }
        }
        .padding(32)
    }
}
```

- Drag the top card in any direction — if it travels past the default threshold (100 pt), it animates away and moves to the bottom of the stack.
- Change `currentCard` programmatically to bring any card to the top.
- Adjust `threshold` to make swiping easier or harder.

## API

### `CardStack`

| Parameter | Type | Description |
| --- | --- | --- |
| `currentCard` | `Binding<Int>` | The ID of the top card. Write to it to programmatically switch cards. |
| `threshold` | `CGFloat` | Minimum drag distance to trigger a swipe-away. Defaults to `100`. |
| `content` | `@ViewBuilder () -> Content` | The card views. Each must use `.cardID(_:)`. |

### `.cardID(_:)`

```swift
func cardID(_ id: Int) -> some View
```

Assigns a unique, stable integer ID to a card view so `CardStack` can track and reorder it.

> [!Important]
>
> Every card inside a `CardStack` must carry `.cardID(_:)`. The stack will not show any cards until all IDs have been registered.

## License

MIT
