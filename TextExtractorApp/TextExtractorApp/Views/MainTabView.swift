//
//  MainTabView.swift
//  TextExtractorApp
//
//  Created by speedy on 2024/12/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var recognizer = TextRecognizer()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView(recognizer: recognizer, selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "camera")
                    Text("Scanner")
                }
                .tag(0)
            
            FullTextView(recognizer: recognizer)
                .tabItem {
                    Image(systemName: "doc.text")
                    Text("Full Text")
                }
                .tag(1)
        }
        .accentColor(.purple)
    }
}
