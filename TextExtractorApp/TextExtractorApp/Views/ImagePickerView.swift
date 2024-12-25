//
//  ImagePickerView.swift
//  TextExtractorApp
//
//  Created by speedy on 2024/12/25.
//

import SwiftUI
import UIKit

enum ImageSource: Identifiable {
    case camera
    case photoLibrary
    
    var id: Int {
        switch self {
        case .camera: return 0
        case .photoLibrary: return 1
        }
    }
}

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let source: ImageSource
    let completion: (UIImage?) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        
        switch source {
        case .camera:
            picker.sourceType = .camera
        case .photoLibrary:
            picker.sourceType = .photoLibrary
        }
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let selectedImage: UIImage?
            
            if let editedImage = info[.editedImage] as? UIImage {
                selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                selectedImage = originalImage
            } else {
                selectedImage = nil
            }
            
            if let image = selectedImage {
                parent.image = image
                parent.completion(image)
            }
            
            picker.dismiss(animated: true) {
                self.parent.presentationMode.wrappedValue.dismiss()
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true) {
                self.parent.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct ImagePickerView_Previews: PreviewProvider {
    static var previews: some View {
        ImagePickerView(
            image: .constant(nil),
            source: .photoLibrary
        ) { _ in }
    }
}
