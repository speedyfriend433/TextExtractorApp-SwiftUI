//
//  OCRSettingsView.swift
//  TextExtractorApp
//
//  Created by speedy on 2024/12/25.
//

import SwiftUI
import Combine

struct OCRSettingsView: View {
    @ObservedObject var recognizer: TextRecognizer
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("isDarkMode") private var isDarkMode = false
    @StateObject private var viewModel: OCRSettingsViewModel
    
    init(recognizer: TextRecognizer) {
        self.recognizer = recognizer
        _viewModel = StateObject(wrappedValue: OCRSettingsViewModel(recognizer: recognizer))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Image(systemName: "text.viewfinder")
                            .foregroundColor(StyleConstants.primaryColor)
                            .font(.title2)
                        Text("OCR Settings")
                            .font(.headline)
                    }
                    .listRowBackground(Color.clear)
                }
                
                Section(header: Text("Appearance")
                    .foregroundColor(StyleConstants.primaryColor)) {
                    Toggle(isOn: $isDarkMode) {
                        HStack {
                            Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                                .foregroundColor(isDarkMode ? .yellow : .orange)
                            Text("Dark Mode")
                        }
                    }
                    .onChange(of: isDarkMode) { _ in
                        setAppearance()
                    }
                }
                
                Section(header: Text("Languages")
                    .foregroundColor(StyleConstants.primaryColor)) {
                    ForEach(Array(recognizer.supportedLanguages.keys.sorted()), id: \.self) { code in
                        Toggle(recognizer.supportedLanguages[code] ?? code, isOn: Binding(
                            get: { viewModel.selectedLanguages.contains(code) },
                            set: { isSelected in
                                if isSelected {
                                    viewModel.selectedLanguages.insert(code)
                                } else {
                                    viewModel.selectedLanguages.remove(code)
                                }
                            }
                        ))
                        .tint(StyleConstants.primaryColor)
                    }
                }
                
                Section(header: Text("Recognition Settings")
                    .foregroundColor(StyleConstants.primaryColor)) {
                    Toggle(isOn: $viewModel.useLanguageCorrection) {
                        VStack(alignment: .leading) {
                            Text("Language Correction")
                            Text("Improve accuracy using language context")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .tint(StyleConstants.primaryColor)
                    
                    Toggle(isOn: $viewModel.autoDetectLanguage) {
                        VStack(alignment: .leading) {
                            Text("Auto Detect Language")
                            Text("Automatically detect text language")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .tint(StyleConstants.primaryColor)
                    
                    VStack(alignment: .leading) {
                        Text("Minimum Text Height")
                        Text("Adjust sensitivity for text detection")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        HStack {
                            Text("\(Int(viewModel.minimumTextHeight * 100))%")
                                .foregroundColor(.gray)
                                .frame(width: 40, alignment: .leading)
                            
                            Slider(value: $viewModel.minimumTextHeight, in: 0.01...0.5)
                                .tint(StyleConstants.primaryColor)
                        }
                    }
                }
                
                if recognizer.confidence > 0 {
                    Section(header: Text("Recognition Quality")
                        .foregroundColor(StyleConstants.primaryColor)) {
                        HStack {
                            Image(systemName: "gauge.medium")
                                .foregroundColor(getConfidenceColor(recognizer.confidence))
                            Text("Confidence Level")
                            Spacer()
                            Text("\(recognizer.confidence * 100, specifier: "%.1f")%")
                                .foregroundColor(getConfidenceColor(recognizer.confidence))
                                .bold()
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        viewModel.saveSettings()
                        dismiss()
                    }
                    .foregroundColor(StyleConstants.primaryColor)
                }
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    private func getConfidenceColor(_ confidence: Double) -> Color {
        switch confidence {
        case 0.8...:
            return .green
        case 0.6..<0.8:
            return .yellow
        default:
            return .red
        }
    }
    
    private func setAppearance() {

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        }
    }
}

struct LanguageToggleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? StyleConstants.primaryColor : backgroundStyle)
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
    }
    
    private var backgroundStyle: Color {
        colorScheme == .dark ? Color.gray.opacity(0.3) : Color.white
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(StyleConstants.primaryColor)
                    .frame(width: 24)
                Text(title)
                    .font(.body)
            }
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.leading, 28)
        }
    }
}

struct OCRSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        OCRSettingsView(recognizer: TextRecognizer())
    }
}
