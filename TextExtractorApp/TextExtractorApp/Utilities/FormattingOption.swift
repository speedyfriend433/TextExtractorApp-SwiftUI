//
//  FormattingOption.swift
//  TextExtractorApp
//
//  Created by speedy on 2024/12/25.
//

import SwiftUI

struct TextStyle: Equatable {
    var font: Font = .body
    var foregroundColor: Color = .black
    var backgroundColor: Color = .clear
    var alignment: Alignment = .leading
    var lineSpacing: CGFloat = 5
    var letterSpacing: CGFloat = 0
}

enum FormattingOption: Identifiable, Hashable {
    case font
    case color
    case background
    case alignment
    case spacing
    case style
    
    var id: String { return String(describing: self) }
    
    var icon: String {
        switch self {
        case .font: return "textformat.size"
        case .color: return "paintpalette.fill"
        case .background: return "square.fill"
        case .alignment: return "text.alignleft"
        case .spacing: return "arrow.up.and.down"
        case .style: return "textformat.alt"
        }
    }
    
    var title: String {
        switch self {
        case .font: return "Font"
        case .color: return "Color"
        case .background: return "Background"
        case .alignment: return "Alignment"
        case .spacing: return "Spacing"
        case .style: return "Style"
        }
    }
}
