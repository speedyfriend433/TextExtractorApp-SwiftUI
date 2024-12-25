//
//  TextRecognizer.swift
//  TextExtractorApp
//
//  Created by speedy on 2024/12/25.
//

import Vision
import UIKit
import CoreImage

// MARK: - Extensions

// Add this extension at the top level
extension UserDefaults {
    func exists(key: String) -> Bool {
        return object(forKey: key) != nil
    }
}

extension Array where Element == Float {
    var average: Float {
        guard !isEmpty else { return 0 }
        return reduce(0, +) / Float(count)
    }
}

enum OCRError: LocalizedError {
    case invalidImage
    case imageProcessingFailed
    case noTextFound
    case lowConfidence
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "The provided image is invalid"
        case .imageProcessingFailed:
            return "Failed to process the image"
        case .noTextFound:
            return "No text was found in the image"
        case .lowConfidence:
            return "The text recognition confidence is too low"
        }
    }
}

class TextRecognizer: ObservableObject {
    @Published var extractedText: String = ""
    @Published var editedText: String = ""
    @Published var confidence: Double = 0.0
    @Published var isProcessing: Bool = false
    @Published var recognitionLanguages: [String]
    
    private let defaults = UserDefaults.standard
    
    let supportedLanguages = [
        "en-US": "English",
        "fr-FR": "French",
        "es-ES": "Spanish",
        "de-DE": "German",
        "it-IT": "Italian",
        "pt-BR": "Portuguese",
        "zh-Hans": "Simplified Chinese",
        "zh-Hant": "Traditional Chinese",
        "ja-JP": "Japanese",
        "ko-KR": "Korean"
    ]
    
    struct OCRConfiguration {
        var minimumTextHeight: Float
        var recognitionLevel: VNRequestTextRecognitionLevel
        var useLanguageCorrection: Bool
        var customWords: [String]
        var automaticallyDetectsLanguage: Bool
    }
    
    private var configuration: OCRConfiguration
    
    init() {

        if let savedLanguages = UserDefaults.standard.stringArray(forKey: "selectedLanguages") {
            self.recognitionLanguages = savedLanguages
        } else {
            self.recognitionLanguages = ["en-US"]
            UserDefaults.standard.set(["en-US"], forKey: "selectedLanguages")
        }
        
        let savedMinHeight = Float(UserDefaults.standard.double(forKey: "minimumTextHeight"))
        _ = UserDefaults.standard.bool(forKey: "useLanguageCorrection")
        _ = UserDefaults.standard.bool(forKey: "autoDetectLanguage")
        
        // Use nil coalescing for default values instead of exists check
        configuration = OCRConfiguration(
            minimumTextHeight: savedMinHeight > 0 ? savedMinHeight : 0.1,
            recognitionLevel: .accurate,
            useLanguageCorrection: UserDefaults.standard.object(forKey: "useLanguageCorrection") as? Bool ?? true,
            customWords: [],
            automaticallyDetectsLanguage: UserDefaults.standard.object(forKey: "autoDetectLanguage") as? Bool ?? true
        )
    }
    
    func recognizeText(from image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        isProcessing = true
        
        guard let processedImage = preProcessImage(image) else {
            isProcessing = false
            completion(.failure(OCRError.imageProcessingFailed))
            return
        }
        
        guard let cgImage = processedImage.cgImage else {
            isProcessing = false
            completion(.failure(OCRError.invalidImage))
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    completion(.failure(error))
                }
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    completion(.failure(OCRError.noTextFound))
                }
                return
            }
            
            var recognizedText: [(text: String, confidence: Float)] = []
            
            for observation in observations {
                if let candidate = observation.topCandidates(1).first {
                    recognizedText.append((candidate.string, candidate.confidence))
                }
            }
            
            recognizedText.sort { $0.confidence > $1.confidence }
            
            let confidenceValues = recognizedText.map { $0.confidence }
            let averageConfidence = confidenceValues.average
            let processedText = recognizedText.map { $0.text }.joined(separator: "\n")
            
            DispatchQueue.main.async {
                self.confidence = Double(averageConfidence)
                self.extractedText = processedText
                self.editedText = processedText
                self.isProcessing = false
                completion(.success(processedText))
            }
        }
        
        configureTextRequest(request)
        
        do {
            try requestHandler.perform([request])
        } catch {
            isProcessing = false
            completion(.failure(error))
        }
    }
    
    func setRecognitionLanguages(_ languages: [String]) {
        recognitionLanguages = languages
        UserDefaults.standard.set(languages, forKey: "selectedLanguages")
    }
    
    func updateConfiguration(
        minimumTextHeight: Float? = nil,
        recognitionLevel: VNRequestTextRecognitionLevel? = nil,
        useLanguageCorrection: Bool? = nil,
        customWords: [String]? = nil,
        automaticallyDetectsLanguage: Bool? = nil
    ) {
        if let height = minimumTextHeight {
            configuration.minimumTextHeight = height
            UserDefaults.standard.set(Double(height), forKey: "minimumTextHeight")
        }
        
        if let useCorrection = useLanguageCorrection {
            configuration.useLanguageCorrection = useCorrection
            UserDefaults.standard.set(useCorrection, forKey: "useLanguageCorrection")
        }
        
        if let autoDetect = automaticallyDetectsLanguage {
            configuration.automaticallyDetectsLanguage = autoDetect
            UserDefaults.standard.set(autoDetect, forKey: "autoDetectLanguage")
        }
        
        if let level = recognitionLevel {
            configuration.recognitionLevel = level
        }
        
        if let words = customWords {
            configuration.customWords = words
        }
    }
    
    private func preProcessImage(_ image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return image }
        
        let context = CIContext(options: nil)
        
        var processedImage = ciImage
        processedImage = enhanceContrast(processedImage) ?? processedImage
        processedImage = removeNoise(processedImage) ?? processedImage
        processedImage = sharpenImage(processedImage) ?? processedImage
        
        guard let outputCGImage = context.createCGImage(processedImage, from: processedImage.extent) else {
            return image
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func enhanceContrast(_ image: CIImage) -> CIImage? {
        return image.applyingFilter("CIColorControls", parameters: [
            "inputContrast": 1.1,
            "inputBrightness": 0.1
        ])
    }
    
    private func removeNoise(_ image: CIImage) -> CIImage? {
        return image.applyingFilter("CINoiseReduction", parameters: [
            "inputNoiseLevel": 0.02,
            "inputSharpness": 0.4
        ])
    }
    
    private func sharpenImage(_ image: CIImage) -> CIImage? {
        return image.applyingFilter("CISharpenLuminance", parameters: [
            "inputSharpness": 0.5
        ])
    }
    
    private func configureTextRequest(_ request: VNRecognizeTextRequest) {
        request.recognitionLevel = configuration.recognitionLevel
        request.usesLanguageCorrection = configuration.useLanguageCorrection
        request.minimumTextHeight = configuration.minimumTextHeight
        request.customWords = configuration.customWords
        request.recognitionLanguages = recognitionLanguages
        request.automaticallyDetectsLanguage = configuration.automaticallyDetectsLanguage
    }
    
    // To-Do :missing symbol fix (spacing)
    
    // MARK: - Error Handling
    
    enum OCRError: LocalizedError {
        case invalidImage
        case imageProcessingFailed
        case noTextFound
        case lowConfidence
        
        var errorDescription: String? {
            switch self {
            case .invalidImage:
                return "The provided image is invalid"
            case .imageProcessingFailed:
                return "Failed to process the image"
            case .noTextFound:
                return "No text was found in the image"
            case .lowConfidence:
                return "The text recognition confidence is too low"
            }
        }
    }
}
