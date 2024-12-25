//
//  FullTextView.swift
//  TextExtractorApp
//
//  Created by speedy on 2024/12/25.
//

import SwiftUI

struct FullTextView: View {
    @ObservedObject var recognizer: TextRecognizer
    @State private var searchText = ""
    @State private var isEditing = false
    @State private var showingFormatting = false
    @State private var textStyle = TextStyle()
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingSaveConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                StyleConstants.backgroundGradient(for: colorScheme)
                
                VStack {
                    if isEditing {
                        TextEditor(text: $recognizer.editedText)
                            .font(textStyle.font)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .padding()
                            .background(colorScheme == .dark ? Color(UIColor.systemGray6) : .white)
                            .cornerRadius(StyleConstants.cornerRadius)
                            .padding()
                            .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.1),
                                   radius: 5, x: 0, y: 2)
                    } else {
                        ScrollView {
                            Text(searchText.isEmpty ? recognizer.editedText : filteredText)
                                .font(textStyle.font)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .frame(maxWidth: .infinity, alignment: textStyle.alignment)
                                .lineSpacing(textStyle.lineSpacing)
                                .tracking(textStyle.letterSpacing)
                                .padding()
                                .background(
                                    colorScheme == .dark ?
                                        Color(UIColor.systemGray6) :
                                        Color.white
                                )
                                .cornerRadius(StyleConstants.cornerRadius)
                                .padding()
                                .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.1),
                                       radius: 5, x: 0, y: 2)
                                .contextMenu {
                                    Button(action: {
                                        UIPasteboard.general.string = recognizer.editedText
                                        let generator = UINotificationFeedbackGenerator()
                                        generator.notificationOccurred(.success)
                                    }) {
                                        Label("Copy All", systemImage: "doc.on.doc")
                                    }
                                    
                                    Button(action: {
                                        shareText(recognizer.editedText)
                                    }) {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    }
                                }
                        }
                    }
                }
                .navigationTitle("Full Text")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showingFormatting.toggle()
                        }) {
                            Image(systemName: "textformat.size")
                                .foregroundColor(StyleConstants.primaryColor)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            withAnimation {
                                isEditing.toggle()
                                if !isEditing {
                                    showingSaveConfirmation = true
                                }
                            }
                        }) {
                            Text(isEditing ? "Done" : "Edit")
                                .foregroundColor(StyleConstants.primaryColor)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingFormatting) {
                BeautifulFormattingView(textStyle: $textStyle)
            }
            .searchable(text: $searchText, prompt: "Search in text")
            .alert("Text Saved", isPresented: $showingSaveConfirmation) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your changes have been saved.")
            }
        }
    }
    
    private var filteredText: String {
        recognizer.editedText.components(separatedBy: "\n")
            .filter { $0.lowercased().contains(searchText.lowercased()) }
            .joined(separator: "\n")
    }
    
    private func shareText(_ text: String) {
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(av, animated: true)
        }
    }
}
    
    /*private var alignment: Alignment {
        switch formatting.alignment {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }*/
    
struct FormattingToolbar: View {
    @Binding var formatting: TextFormatting
    
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                Button(action: { formatting.isBold.toggle() }) {
                    Image(systemName: "bold")
                        .foregroundColor(formatting.isBold ? .purple : .gray)
                }
                
                Button(action: { formatting.isItalic.toggle() }) {
                    Image(systemName: "italic")
                        .foregroundColor(formatting.isItalic ? .purple : .gray)
                }
                
                Divider()
                
                HStack {
                    Button(action: { formatting.alignment = .leading }) {
                        Image(systemName: "text.alignleft")
                            .foregroundColor(formatting.alignment == .leading ? .purple : .gray)
                    }
                    
                    Button(action: { formatting.alignment = .center }) {
                        Image(systemName: "text.aligncenter")
                            .foregroundColor(formatting.alignment == .center ? .purple : .gray)
                    }
                    
                    Button(action: { formatting.alignment = .trailing }) {
                        Image(systemName: "text.alignright")
                            .foregroundColor(formatting.alignment == .trailing ? .purple : .gray)
                    }
                }
                
                Divider()
                
                ColorPicker("", selection: $formatting.textColor)
            }
            .padding()
            
            HStack {
                Text("Font Size: \(Int(formatting.fontSize))")
                    .foregroundColor(.gray)
                Slider(value: $formatting.fontSize, in: 12...24, step: 1)
            }
            .padding(.horizontal)
        }
        .background(Color.white)
        .cornerRadius(15)
        .padding()
        .shadow(radius: 5)
    }
}

struct FullTextView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FullTextView(recognizer: TextRecognizer())
                .preferredColorScheme(.light)
            
            FullTextView(recognizer: TextRecognizer())
                .preferredColorScheme(.dark)
        }
    }
}
