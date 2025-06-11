//
//  EditorViewModel.swift
//  SwiftUI-App-Boilerplate
//
//  Created by Arek on 21/10/2023.
//

import SwiftUI
import PhotosUI

// MARK: - Circle Model
struct EditableCircle: Identifiable, Equatable {
    let id = UUID()
    var position: CGPoint  // Position relative to the image (normalized 0-1)
    var width: CGFloat = 100  // Width in points
    var height: CGFloat = 50  // Height in points
    
    init(position: CGPoint) {
        self.position = position
    }
}

@Observable final class EditorViewModel {

    var selectedPhoto: PhotosPickerItem?
    var selectedImage: UIImage?
    var imageScale: CGFloat = 1.0
    var imageOffset: CGSize = .zero
    var isDetectingFaces = false
    
    // MARK: - Circle Management
    var circles: [EditableCircle] = []
    
    func loadImage() async {
        guard let selectedPhoto else { return }
        
        do {
            if let data = try await selectedPhoto.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    self.selectedImage = uiImage
                    self.resetZoom()
                    self.clearCircles()
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
    
    func clearCircles() {
        circles.removeAll()
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
        
        // Add a new circle at the center of the visible area
        let newCircle = EditableCircle(position: CGPoint(x: 0.5, y: 0.5))
        circles.append(newCircle)
        
        print("Added circle at center - Total circles: \(circles.count)")
    }
    
    func updateCirclePosition(_ circle: EditableCircle, to newPosition: CGPoint) {
        guard let index = circles.firstIndex(of: circle) else { return }
        circles[index].position = newPosition
    }
    
    func updateCircleSize(_ circle: EditableCircle, width: CGFloat, height: CGFloat) {
        guard let index = circles.firstIndex(of: circle) else { return }
        // Ensure minimum size constraints
        let minSize: CGFloat = 30
        circles[index].width = max(minSize, width)
        circles[index].height = max(minSize, height)
    }
    
    func removeCircle(_ circle: EditableCircle) {
        circles.removeAll { $0.id == circle.id }
    }
    
    func exportImage() {
        guard let selectedImage else { return }
        
        // TODO: Implement export functionality with blur applied
        print("Exporting image...")
        
        // Save to Photos library (simplified implementation)
        UIImageWriteToSavedPhotosAlbum(selectedImage, nil, nil, nil)
    }
} 
