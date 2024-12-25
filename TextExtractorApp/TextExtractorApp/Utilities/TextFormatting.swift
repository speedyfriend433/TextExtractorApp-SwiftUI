//
//  TextFormatting.swift
//  TextExtractorApp
//
//  Created by speedy on 2024/12/25.
//

import SwiftUI

struct TextFormatting {
    var isBold: Bool = false
    var isItalic: Bool = false
    var fontSize: CGFloat = 16
    var textColor: Color = .black
    var alignment: TextAlignment = .leading
}

enum TextAlignment {
    case leading, center, trailing
}
