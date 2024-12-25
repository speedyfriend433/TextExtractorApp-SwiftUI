# TextExtractorApp-SwiftUI

A modern iOS app built with SwiftUI that extracts text from images using Vision framework. Features include camera integration, photo library support, text formatting, and dark mode support.

## Features
- 📷 Camera and Photo Library Integration
- 🔍 OCR (Optical Character Recognition)
- 🌓 Dark Mode Support
- ✏️ Text Formatting Options
- 🌍 Multi-language Support
- ⚙️ Customizable OCR Settings
- 💾 Persistent Settings
- 📋 Copy and Share Functionality

## Screenshots
![B081D151-A82A-4C4A-9B59-F621B4DFC406](https://github.com/user-attachments/assets/cab45017-77c9-4658-b75e-823a16729036)
![BA45639B-3CE3-43B9-9271-F87AC4CE0F33](https://github.com/user-attachments/assets/a51aab68-c6eb-494f-b078-70d32a9ce1a8)
![1EF69210-325E-4595-A713-1043FCEB2746](https://github.com/user-attachments/assets/fa26f539-2d61-4d9c-8510-27e1c3ac5a97)
![477F0627-A688-439C-A863-30B8AB708C0F](https://github.com/user-attachments/assets/87482548-e0fd-4ffd-803f-77bd138a38e7)

## Requirements
- iOS 16.0+ (Because of 'tracking' function, Sorry for iOS 14-15 Users 😔)
- Xcode 13.0+
- Swift 5.5+

## Installation
```bash
Clone the repository
git clone https://github.com/Speedyfriend433/TextExtractorApp-SwiftUI.git
Open the project in Xcode
cd TextExtractorApp-SwiftUI
open TextExtractorApp.xcodeproj
Build and run the project
```

## Usage

Text Extraction : 

- Launch the app
- Choose between camera or photo library
- Take/Select a photo containing text
- Wait for the text extraction process
- View and edit the extracted text

Text Formatting : 

- Font styles
- Text colors
- Background colors
- Text alignment
- Line spacing
- Letter spacing

OCR Settings : 

- Language selection
- Minimum text height
- Language correction
- Auto-detect language

## Architecture
The app follows a clean architecture pattern with:

- SwiftUI for the UI layer
- Vision framework for OCR
- Combine for reactive programming
- UserDefaults for persistence

## Key Components

Views : 
- ContentView: Main scanner interface
- FullTextView: Complete extracted text view
- BeautifulFormattingView: Text formatting options
- OCRSettingsView: OCR configuration

Models : 
- TextRecognizer: Handles OCR operations
- TextStyle: Manages text formatting
- OCRSettingsViewModel: Manages OCR settings

## Permissions
The app requires the following permissions:

```bash
- Camera access
- Photo library access
```

Add these to your Info.plist:

```bash
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to capture images for text extraction.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to select images for text extraction.</string>
```

## Contributing

1. Fork the repository
2. Create your feature branch (git checkout -b feature/AmazingFeature)
3. Commit your changes (git commit -m 'Add some AmazingFeature')
4. Push to the branch (git push origin feature/AmazingFeature)
5. Open a Pull Request

## Author

speedyfriend67 - Speedyfriend433

## License

This project is licensed under the MIT License - see the LICENSE file for details

## Acknowledgments

- Vision framework for OCR capabilities
-  SwiftUI for modern UI development
- The Swift community for inspiration and support
- Feel free to star ⭐️ the repo if you like what you see!

## Contact

speedyfriend67 - GitHub

Project Link: https://github.com/Speedyfriend433/TextExtractorApp-SwiftUI
