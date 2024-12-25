//
//  BeautifulFormattingView.swift
//  TextExtractorApp
//
//  Created by speedy on 2024/12/25.
//

import SwiftUI

struct BeautifulFormattingView: View {
    @Binding var textStyle: TextStyle
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedOption: FormattingOption?
    
    var body: some View {
        NavigationView {
            ZStack {
                StyleConstants.backgroundGradient(for: colorScheme)
                
                VStack(spacing: 20) {

                    PreviewCard(textStyle: textStyle, colorScheme: colorScheme)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        ForEach(options) { option in
                            OptionButton(
                                option: option,
                                isSelected: selectedOption == option,
                                colorScheme: colorScheme,
                                action: { selectOption(option) }
                            )
                        }
                    }
                    .padding()
                    
                    if let selectedOption = selectedOption {
                        OptionDetailView(
                            option: selectedOption,
                            textStyle: $textStyle,
                            colorScheme: colorScheme
                        )
                        .transition(.move(edge: .bottom))
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Text Formatting")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(StyleConstants.primaryColor)
                }
            }
        }
    }
    
    private let options: [FormattingOption] = [
        .font, .color, .background, .alignment, .spacing, .style
    ]
    
    private func selectOption(_ option: FormattingOption) {
        withAnimation(.spring()) {
            if selectedOption == option {
                selectedOption = nil
            } else {
                selectedOption = option
            }
        }
    }
}

struct PreviewCard: View {
    let textStyle: TextStyle
    let colorScheme: ColorScheme
    
    var body: some View {
        VStack {
            Text("Preview Text")
                .font(textStyle.font)
                .foregroundColor(textStyle.foregroundColor)
                .frame(maxWidth: .infinity, alignment: textStyle.alignment)
                .lineSpacing(textStyle.lineSpacing)
                .tracking(textStyle.letterSpacing)
                .padding()
                .background(textStyle.backgroundColor)
        }
        .frame(maxWidth: .infinity)
        .background(colorScheme == .dark ? Color(UIColor.systemGray6) : .white)
        .cornerRadius(StyleConstants.cornerRadius)
        .shadow(color: colorScheme == .dark ? .clear : StyleConstants.shadowColor,
                radius: 10)
        .padding()
    }
}

struct OptionButton: View {
    let option: FormattingOption
    let isSelected: Bool
    let colorScheme: ColorScheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: option.icon)
                    .font(.system(size: 24))
                Text(option.title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1.0, contentMode: .fit)
            .padding()
            .background(buttonBackground)
            .foregroundColor(buttonForeground)
            .cornerRadius(StyleConstants.cornerRadius)
            .shadow(color: colorScheme == .dark ? .clear : StyleConstants.shadowColor,
                    radius: 5)
        }
    }
    
    private var buttonBackground: Color {
        if isSelected {
            return StyleConstants.primaryColor
        }
        return colorScheme == .dark ? Color(UIColor.systemGray6) : .white
    }
    
    private var buttonForeground: Color {
        if isSelected {
            return .white
        }
        return colorScheme == .dark ? .white : .primary
    }
}

struct OptionDetailView: View {
    let option: FormattingOption
    @Binding var textStyle: TextStyle
    let colorScheme: ColorScheme
    
    var body: some View {
        VStack {
            switch option {
            case .font:
                FontOptionView(textStyle: $textStyle, colorScheme: colorScheme)
            case .color:
                ColorOptionView(textStyle: $textStyle, colorScheme: colorScheme)
            case .background:
                BackgroundColorView(textStyle: $textStyle, colorScheme: colorScheme)
            case .alignment:
                AlignmentView(textStyle: $textStyle, colorScheme: colorScheme)
            case .spacing:
                SpacingView(textStyle: $textStyle, colorScheme: colorScheme)
            case .style:
                StyleView(textStyle: $textStyle, colorScheme: colorScheme)
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color(UIColor.systemGray6) : .white)
        .cornerRadius(StyleConstants.cornerRadius)
        .shadow(color: colorScheme == .dark ? .clear : StyleConstants.shadowColor,
                radius: 5)
        .padding(.horizontal)
    }
}

struct FontOptionView: View {
    @Binding var textStyle: TextStyle
    let colorScheme: ColorScheme
    
    private let fonts: [(name: String, font: Font)] = [
        ("System", .body),
        ("Rounded", .system(.body, design: .rounded)),
        ("Serif", .system(.body, design: .serif)),
        ("Monospaced", .system(.body, design: .monospaced))
    ]
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Font Style")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(fonts, id: \.name) { font in
                        Button(action: {
                            withAnimation {
                                textStyle.font = font.font
                            }
                        }) {
                            Text("Aa")
                                .font(font.font)
                                .padding()
                                .foregroundColor(colorScheme == .dark ? .white : .primary)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(textStyle.font == font.font ?
                                               StyleConstants.primaryColor :
                                               Color.gray,
                                               lineWidth: 2)
                                )
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct ColorOptionView: View {
    @Binding var textStyle: TextStyle
    let colorScheme: ColorScheme
    
    private let colors: [Color] = [
        .primary,
        .blue,
        .red,
        .green,
        .purple,
        .orange
    ]
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Text Color")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .primary)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 15) {
                ForEach(colors, id: \.self) { color in
                    ColorButton(
                        color: color,
                        isSelected: textStyle.foregroundColor == color,
                        colorScheme: colorScheme
                    ) {
                        textStyle.foregroundColor = color
                    }
                }
            }
            
            ColorPicker("Custom Color", selection: $textStyle.foregroundColor)
                .padding(.top)
        }
    }
}

struct BackgroundColorView: View {
    @Binding var textStyle: TextStyle
    let colorScheme: ColorScheme
    
    private let colors: [Color] = [
        .clear,
        .blue.opacity(0.1),
        .green.opacity(0.1),
        .purple.opacity(0.1),
        .orange.opacity(0.1),
        .pink.opacity(0.1)
    ]
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Background Color")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .primary)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 15) {
                ForEach(colors, id: \.self) { color in
                    BackgroundColorButton(
                        color: color,
                        isSelected: textStyle.backgroundColor == color,
                        colorScheme: colorScheme
                    ) {
                        textStyle.backgroundColor = color
                    }
                }
            }
            
            ColorPicker("Custom Background", selection: $textStyle.backgroundColor)
                .padding(.top)
        }
    }
}

struct BackgroundColorButton: View {
    let color: Color
    let isSelected: Bool
    let colorScheme: ColorScheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 40, height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(colorScheme == .dark ? .white : .black, lineWidth: 2)
                        .opacity(0.1)
                )
                .overlay(
                    Image(systemName: "checkmark")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .opacity(isSelected ? 1 : 0)
                )
                .shadow(color: colorScheme == .dark ? .clear : StyleConstants.shadowColor,
                        radius: 3)
        }
    }
}

struct AlignmentView: View {
    @Binding var textStyle: TextStyle
    let colorScheme: ColorScheme
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Text Alignment")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .primary)
            
            HStack(spacing: 20) {
                AlignmentButton(
                    title: "Left",
                    icon: "text.alignleft",
                    alignment: .leading,
                    currentAlignment: textStyle.alignment,
                    colorScheme: colorScheme
                ) {
                    textStyle.alignment = .leading
                }
                
                AlignmentButton(
                    title: "Center",
                    icon: "text.aligncenter",
                    alignment: .center,
                    currentAlignment: textStyle.alignment,
                    colorScheme: colorScheme
                ) {
                    textStyle.alignment = .center
                }
                
                AlignmentButton(
                    title: "Right",
                    icon: "text.alignright",
                    alignment: .trailing,
                    currentAlignment: textStyle.alignment,
                    colorScheme: colorScheme
                ) {
                    textStyle.alignment = .trailing
                }
            }
        }
    }
}

struct AlignmentButton: View {
    let title: String
    let icon: String
    let alignment: Alignment
    let currentAlignment: Alignment
    let colorScheme: ColorScheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.caption)
            }
            .frame(width: 80)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(currentAlignment == alignment ?
                          StyleConstants.primaryColor :
                          (colorScheme == .dark ? Color(UIColor.systemGray6) : .white))
            )
            .foregroundColor(currentAlignment == alignment ? .white :
                            (colorScheme == .dark ? .white : .primary))
            .shadow(color: colorScheme == .dark ? .clear : StyleConstants.shadowColor,
                    radius: 3)
        }
    }
}

struct SpacingView: View {
    @Binding var textStyle: TextStyle
    let colorScheme: ColorScheme
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Spacing")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .primary)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Line Spacing")
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                HStack {
                    Text("\(Int(textStyle.lineSpacing))")
                        .foregroundColor(.gray)
                        .frame(width: 30, alignment: .leading)
                    Slider(value: $textStyle.lineSpacing, in: 0...20)
                        .tint(StyleConstants.primaryColor)
                }
                
                Text("Letter Spacing")
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                    .padding(.top, 8)
                HStack {
                    Text("\(Int(textStyle.letterSpacing))")
                        .foregroundColor(.gray)
                        .frame(width: 30, alignment: .leading)
                    Slider(value: $textStyle.letterSpacing, in: 0...10)
                        .tint(StyleConstants.primaryColor)
                }
            }
        }
    }
}

struct StyleView: View {
    @Binding var textStyle: TextStyle
    let colorScheme: ColorScheme
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Text Style")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .primary)
            
            Text("Additional style options coming soon...")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}

struct ColorButton: View {
    let color: Color
    let isSelected: Bool
    let colorScheme: ColorScheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(colorScheme == .dark ? .white : .black, lineWidth: 2)
                        .opacity(0.1)
                )
                .overlay(
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .opacity(isSelected ? 1 : 0)
                )
                .shadow(color: colorScheme == .dark ? .clear : StyleConstants.shadowColor,
                        radius: 3)
        }
    }
}

struct BeautifulFormattingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BeautifulFormattingView(textStyle: .constant(TextStyle()))
                .preferredColorScheme(.light)
            
            BeautifulFormattingView(textStyle: .constant(TextStyle()))
                .preferredColorScheme(.dark)
        }
    }
}
