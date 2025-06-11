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
    var isDetectingFaces = false
    var isAddingShape = false
    
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
    
    func detectFaces() async {
        guard selectedImage != nil else { return }
        
        await MainActor.run {
            isDetectingFaces = true
        }
        
        // Simulate face detection processing
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await MainActor.run {
            isDetectingFaces = false
            // TODO: Implement actual face detection logic
            print("Face detection completed")
        }
    }
    
    func addShape() {
        guard selectedImage != nil else { return }
        
        isAddingShape.toggle()
        // TODO: Implement shape addition logic
        print("Add shape mode: \(isAddingShape)")
    }
    
    func exportImage() {
        guard let selectedImage else { return }
        
        // TODO: Implement export functionality
        print("Exporting image...")
        
        // Save to Photos library (simplified implementation)
        UIImageWriteToSavedPhotosAlbum(selectedImage, nil, nil, nil)
    }
} 
