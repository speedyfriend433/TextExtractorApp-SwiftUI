//
//  ExtractedTextView.swift
//  TextExtractorApp
//
//  Created by speedy on 2024/12/25.
//

import SwiftUI

struct ExtractedTextView: View {
    let text: String
    
    var body: some View {
        ScrollView {
            Text(text.isEmpty ? "No text extracted yet" : text)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.8))
                .cornerRadius(15)
                .padding(.horizontal)
        }
        .animation(.easeInOut, value: text)
    }
}
