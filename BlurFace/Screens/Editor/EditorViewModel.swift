//
//  EditorViewModel.swift
//  BlurFace
//
//  Created by Arek on 21/10/2023.
//

import SwiftUI
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins

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
    var selectedCircleId: UUID?
    
    // MARK: - Export Management
    var showShareSheet = false
    var exportedImage: UIImage?

    let storeManager: StoreManager
    var showPaywall = false

    init(storeManager: StoreManager = RevenueCatStoreManager()) {
        self.storeManager = storeManager
    }

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
        selectedCircleId = nil
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
        
        // Automatically select the newly created circle
        selectedCircleId = newCircle.id
        
        print("Added circle at center - Total circles: \(circles.count)")
    }
    
    func updateCirclePosition(_ circle: EditableCircle, to newPosition: CGPoint) {
        guard let index = circles.firstIndex(of: circle) else { return }
        circles[index].position = newPosition
    }
    
    func updateCircleSize(_ circle: EditableCircle, width: CGFloat, height: CGFloat) {
        guard let index = circles.firstIndex(of: circle) else { return }
        // Ensure minimum size constraints
        let minSize: CGFloat = 20
        circles[index].width = max(minSize, width)
        circles[index].height = max(minSize, height)
    }
    
    func removeCircle(_ circle: EditableCircle) {
        circles.removeAll { $0.id == circle.id }
        if selectedCircleId == circle.id {
            selectedCircleId = nil
        }
    }
    
    // MARK: - Selection Management
    func selectCircle(_ circle: EditableCircle) {
        selectedCircleId = circle.id
    }
    
    func deselectCircle() {
        selectedCircleId = nil
    }
    
    func isCircleSelected(_ circle: EditableCircle) -> Bool {
        return selectedCircleId == circle.id
    }
    
    func onTapExportImage() async {
        let isPro = try? await storeManager.isProEnabled()

        if isPro ?? true {
            export()
        } else {
            showPaywall = true
        }
    }

    func onHidePaywall() {
        export()
    }

    private func export() {
        guard let selectedImage else { return }
        print("Exporting image...")

        // Render the final image with blur effects
        if let processedImage = renderImageWithBlur(selectedImage) {
            exportedImage = processedImage
            showShareSheet = true
        }
    }

    private func renderImageWithBlur(_ originalImage: UIImage) -> UIImage? {
        guard !circles.isEmpty else {
            // If no circles, return original image
            return originalImage
        }
        
        // First, create a blurred version of the entire image
        guard let blurredImage = createBlurredImage(originalImage) else {
            return originalImage
        }

        let imageSize = originalImage.size
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            
            // Draw the original image as base
            originalImage.draw(at: .zero)
            
            // For each circle, draw the blurred version in that area
            for circle in circles {
                // Calculate circle position in image coordinates
                let centerX = circle.position.x * imageSize.width
                let centerY = circle.position.y * imageSize.height
                
                // Convert circle size from display coordinates to image coordinates
                // Calculate scaling factor based on how the image is displayed in the editor
                // The image is displayed with .aspectRatio(contentMode: .fit) within a typical screen size
                let typicalDisplayWidth: CGFloat = 375.0  // iPhone display width
                let typicalDisplayHeight: CGFloat = 667.0 // iPhone display height
                
                // Calculate how the image would be scaled when displayed with .fit aspect ratio
                let imageAspect = imageSize.width / imageSize.height
                let displayAspect = typicalDisplayWidth / typicalDisplayHeight
                
                let displayedImageSize: CGSize
                if imageAspect > displayAspect {
                    // Image is wider, constrained by width
                    displayedImageSize = CGSize(
                        width: typicalDisplayWidth,
                        height: typicalDisplayWidth / imageAspect
                    )
                } else {
                    // Image is taller, constrained by height  
                    displayedImageSize = CGSize(
                        width: typicalDisplayHeight * imageAspect,
                        height: typicalDisplayHeight
                    )
                }
                
                // Calculate scaling factors from displayed size to actual image size
                let scaleX = imageSize.width / displayedImageSize.width
                let scaleY = imageSize.height / displayedImageSize.height
                
                let imageWidth = circle.width * scaleX
                let imageHeight = circle.height * scaleY
                
                let rect = CGRect(
                    x: centerX - (imageWidth / 2),
                    y: centerY - (imageHeight / 2),
                    width: imageWidth,
                    height: imageHeight
                )
                
                // Save graphics state
                cgContext.saveGState()
                
                // Create elliptical clipping path
                cgContext.addEllipse(in: rect)
                cgContext.clip()
                
                // Draw the blurred image (only the clipped area will be visible)
                blurredImage.draw(at: .zero)
                
                // Restore graphics state
                cgContext.restoreGState()
            }
        }
    }
    
    private func createBlurredImage(_ image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        let context = CIContext()
        
        // Apply Gaussian blur with higher radius for more visible effect
        let blurFilter = CIFilter.gaussianBlur()
        blurFilter.inputImage = ciImage
        blurFilter.radius = 50.0 // Increased blur radius for more visible effect

        guard let blurredCIImage = blurFilter.outputImage else { return nil }
        
        // Create cropped version to match original bounds
        let cropRect = ciImage.extent
        let croppedImage = blurredCIImage.cropped(to: cropRect)
        
        guard let cgImage = context.createCGImage(croppedImage, from: cropRect) else { return nil }
        
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
} 
