//
//  OCRSettingsViewModel.swift
//  TextExtractorApp
//
//  Created by speedy on 2024/12/25.
//

import SwiftUI
import Combine

class OCRSettingsViewModel: ObservableObject {
    private let recognizer: TextRecognizer
    
    @Published var selectedLanguages: Set<String>
    @Published var minimumTextHeight: Double
    @Published var useLanguageCorrection: Bool
    @Published var autoDetectLanguage: Bool
    
    init(recognizer: TextRecognizer) {
        self.recognizer = recognizer
        
        let defaults = UserDefaults.standard
        let savedLanguages = defaults.stringArray(forKey: "selectedLanguages") ?? []
        self.selectedLanguages = Set(savedLanguages.isEmpty ? recognizer.recognitionLanguages : savedLanguages)
        
        let savedHeight = defaults.double(forKey: "minimumTextHeight")
        self.minimumTextHeight = savedHeight > 0 ? savedHeight : 0.1
        
        self.useLanguageCorrection = defaults.object(forKey: "useLanguageCorrection") != nil ?
            defaults.bool(forKey: "useLanguageCorrection") : true
        
        self.autoDetectLanguage = defaults.object(forKey: "autoDetectLanguage") != nil ?
            defaults.bool(forKey: "autoDetectLanguage") : true
        
        setupObservers()
    }
    
    private func setupObservers() {
        observeAndSave()
    }
    
    private func observeAndSave() {
        let defaults = UserDefaults.standard
        
        $selectedLanguages
            .dropFirst()
            .sink { languages in
                defaults.set(Array(languages), forKey: "selectedLanguages")
            }
            .store(in: &cancellables)
        
        $minimumTextHeight
            .dropFirst()
            .sink { height in
                defaults.set(height, forKey: "minimumTextHeight")
            }
            .store(in: &cancellables)
        
        $useLanguageCorrection
            .dropFirst()
            .sink { value in
                defaults.set(value, forKey: "useLanguageCorrection")
            }
            .store(in: &cancellables)
        
        $autoDetectLanguage
            .dropFirst()
            .sink { value in
                defaults.set(value, forKey: "autoDetectLanguage")
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()
    
    func saveSettings() {
        recognizer.setRecognitionLanguages(Array(selectedLanguages))
        recognizer.updateConfiguration(
            minimumTextHeight: Float(minimumTextHeight),
            useLanguageCorrection: useLanguageCorrection,
            automaticallyDetectsLanguage: autoDetectLanguage
        )
    }
}
