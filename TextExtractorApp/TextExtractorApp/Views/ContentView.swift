//
//  ContentView.swift
//  TextExtractorApp
//
//  Created by speedy on 2024/12/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var recognizer: TextRecognizer
    @Binding var selectedTab: Int
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var selectedImage: UIImage?
    @State private var imageSource: ImageSource?
    @State private var isAnimating = false
    @State private var isProcessing = false
    @State private var showingOCRSettings = false
    @State private var showingSaveConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                StyleConstants.backgroundGradient(for: colorScheme)
                
                VStack(spacing: 20) {
                    Text("Text Extractor")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.purple)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isAnimating)
                    
                    ZStack {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 300)
                                .cornerRadius(20)
                                .shadow(radius: 10)
                                .transition(.scale)
                        } else {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 300)
                                .overlay(
                                    VStack(spacing: 12) {
                                        Image(systemName: "doc.text.viewfinder")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white)
                                        Text("Tap to scan text")
                                            .foregroundColor(.white)
                                    }
                                )
                        }
                        
                        if isProcessing {
                            ProgressView()
                                .scaleEffect(1.5)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                    }
                    .onTapGesture {
                        showImageSourcePicker()
                    }
                    
                    HStack(spacing: 20) {
                        ImageSourceButton(
                            title: "Camera",
                            systemImage: "camera",
                            action: { imageSource = .camera }
                        )
                        
                        ImageSourceButton(
                            title: "Photos",
                            systemImage: "photo.on.rectangle",
                            action: { imageSource = .photoLibrary }
                        )
                    }
                    .padding(.horizontal)
                    
                    ScrollView {
                        VStack {
                            Text(recognizer.editedText)
                                .lineLimit(5)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(15)
                                .padding(.horizontal)
                            
                            if !recognizer.editedText.isEmpty {
                                Button(action: {
                                    withAnimation {
                                        selectedTab = 1
                                    }
                                }) {
                                    Text("See All")
                                        .foregroundColor(.purple)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .shadow(radius: 2)
                                }
                            }
                        }
                    }
                    
                    if !recognizer.editedText.isEmpty {
                        Button(action: {
                            UIPasteboard.general.string = recognizer.editedText
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                        }) {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                Text("Copy Text")
                            }
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingOCRSettings.toggle()
                    }) {
                        Image(systemName: "gear")
                            .foregroundColor(.purple)
                    }
                }
            }
            .sheet(item: $imageSource) { source in
                ImagePickerView(image: $selectedImage, source: source) { image in
                    if let image = image {
                        isProcessing = true
                        recognizer.recognizeText(from: image) { result in
                            DispatchQueue.main.async {
                                isProcessing = false
                                switch result {
                                case .success(let text):
                                    print("Successfully extracted text: \(text)")
                                case .failure(let error):
                                    print("Error extracting text: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                }
                .interactiveDismissDisabled(source == .camera)
            }
            .sheet(isPresented: $showingOCRSettings) {
                OCRSettingsView(recognizer: recognizer)
            }
            .onAppear {
                isAnimating = true
            }
        }
    }
    
    private func showImageSourcePicker() {
        let alert = UIAlertController(title: "Choose Image Source",
                                    message: nil,
                                    preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
            imageSource = .camera
        })
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
            imageSource = .photoLibrary
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let viewController = windowScene.windows.first?.rootViewController {
            viewController.present(alert, animated: true)
        }
    }
}

struct ImageSourceButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: systemImage)
                    .font(.system(size: 24))
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white.opacity(0.9))
            .foregroundColor(.purple)
            .cornerRadius(10)
            .shadow(radius: 3)
        }
    }
}

struct ActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                Text(title)
            }
            .padding()
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(recognizer: TextRecognizer(), selectedTab: .constant(0))
    }
}

#Preview {
    ContentView(
        recognizer: TextRecognizer(),
        selectedTab: .constant(0)
    )
}
