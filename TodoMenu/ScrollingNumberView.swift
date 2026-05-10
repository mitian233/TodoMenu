//
//  ScrollingNumberView.swift
//  TodoMenu
//
//  Created by 原田蜜柑 on 2026/05/10.
//

import AppKit
import SwiftUI

struct ScrollingNumberView: View {
    let number: Int
    var digitHeight: CGFloat = 14
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(String(number).enumerated()), id: \.offset) { _, char in
                if let digit = char.wholeNumberValue {
                    ScrollingDigitView(digit: digit, digitHeight: digitHeight)
                } else {
                    Text(String(char))
                }
            }
        }
    }
}

struct ScrollingDigitView: View {
    let digit: Int
    let digitHeight: CGFloat
    
    @State private var animatedDigit: Int
    
    init(digit: Int, digitHeight: CGFloat = 14) {
        self.digit = digit
        self.digitHeight = digitHeight
        self._animatedDigit = State(initialValue: digit)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0...9, id: \.self) { num in
                Text("\(num)")
                    .frame(height: digitHeight, alignment: .center)
            }
        }
        .frame(height: digitHeight, alignment: .top)
        .offset(y: CGFloat(-animatedDigit) * digitHeight)
        .animation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0), value: animatedDigit)
        .clipped()
        .onChange(of: digit) { _, newValue in
            animatedDigit = newValue
        }
    }
}

struct AnimatedRollingNumberView: View {
    let number: Int
    var digitHeight: CGFloat = 14
    var hidesWhenZero: Bool = false

    var isVisible: Bool {
        !hidesWhenZero || number != 0
    }

    var body: some View {
        Group {
            if isVisible {
                ScrollingNumberView(number: number, digitHeight: digitHeight)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.92)),
                        removal: .opacity.combined(with: .scale(scale: 0.92))
                    ))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isVisible)
    }
}
