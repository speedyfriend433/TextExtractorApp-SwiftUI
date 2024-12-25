//
//  StyleConstants.swift
//  TextExtractorApp
//
//  Created by speedy on 2024/12/25.
//

import SwiftUI

struct StyleConstants {
    static let primaryColor: Color = .purple
    static let secondaryColor: Color = .blue
    
    static func backgroundGradient(for colorScheme: ColorScheme) -> some View {
        LinearGradient(
            colors: colorScheme == .dark
                ? [Color.purple.opacity(0.2), Color.blue.opacity(0.2)]
                : [Color.purple.opacity(0.3), Color.blue.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    static func backgroundColor(for colorScheme: ColorScheme) -> LinearGradient {
        switch colorScheme {
        case .light:
            return LinearGradient(
                colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .dark:
            return LinearGradient(
                colors: [Color.purple.opacity(0.2), Color.blue.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        @unknown default:
            return LinearGradient(
                colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    static let cardBackground = Color.white.opacity(0.95)
    static let shadowColor = Color.black.opacity(0.1)
    static let cornerRadius: CGFloat = 15
    static let padding: CGFloat = 16
    
    struct Animation {
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.8)
        static let easeInOut = SwiftUI.Animation.easeInOut(duration: 0.3)
    }
}

    
