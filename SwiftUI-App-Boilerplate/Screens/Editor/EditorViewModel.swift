//
//  EditorViewModel.swift
//  SwiftUI-App-Boilerplate
//
//  Created by Arek on 21/10/2023.
//

import SwiftUI
import PhotosUI

@Observable final class EditorViewModel {
    var selectedPhoto: PhotosPickerItem?
    var selectedImage: UIImage?
    var imageScale: CGFloat = 1.0
    var imageOffset: CGSize = .zero
    
    func loadImage() async {
        guard let selectedPhoto else { return }
        
        do {
            if let data = try await selectedPhoto.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    self.selectedImage = uiImage
                    self.resetZoom()
                }
            }
        } catch {
            print("Error loading image: \(error.localizedDescription)")
        }
    }
    
    func resetZoom() {
        imageScale = 1.0
        imageOffset = .zero
    }
} 