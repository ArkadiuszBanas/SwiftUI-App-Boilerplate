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
    var isExporting = false

    let storeManager: StoreManager
    let ratingRequestManager: RatingRequestManager
    var showPaywall = false

    init(storeManager: StoreManager = RevenueCatStoreManager(),
         ratingRequestManager: RatingRequestManager = RatingRequestManager()) {
        self.storeManager = storeManager
        self.ratingRequestManager = ratingRequestManager
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
    
    func updateCircleSizeAndPosition(_ circle: EditableCircle, width: CGFloat, height: CGFloat, handlePosition: ResizeHandleView.HandlePosition, imageSize: CGSize, imageScale: CGFloat, containerSize: CGSize) {
        guard let index = circles.firstIndex(of: circle) else { return }
        
        // Ensure minimum size constraints
        let minSize: CGFloat = 20
        let newWidth = max(minSize, width)
        let newHeight = max(minSize, height)
        
        // Calculate the change in size (in display coordinates)
        let widthChange = newWidth - circle.width
        let heightChange = newHeight - circle.height
        
        // Calculate the displayed image size using the actual container size
        // This uses the same logic as in MovableCircleView's position calculations
        let imageAspectRatio = imageSize.width / imageSize.height
        let containerAspectRatio = containerSize.width / containerSize.height
        
        let displayedImageSize: CGSize
        if imageAspectRatio > containerAspectRatio {
            // Image is constrained by width
            displayedImageSize = CGSize(
                width: containerSize.width,
                height: containerSize.width / imageAspectRatio
            )
        } else {
            // Image is constrained by height
            displayedImageSize = CGSize(
                width: containerSize.height * imageAspectRatio,
                height: containerSize.height
            )
        }
        
        // widthChange and heightChange are already scale-corrected from ResizeHandleView
        // so we should divide by the base displayed image size, not the scaled one
        let normalizedWidthChange = widthChange / displayedImageSize.width
        let normalizedHeightChange = heightChange / displayedImageSize.height
        
        // Calculate position adjustment based on handle position
        var positionAdjustment = CGPoint.zero
        
        switch handlePosition {
        case .top:
            // When dragging top handle, bottom should stay fixed
            // So center moves up by half the height change
            positionAdjustment.y = -normalizedHeightChange / 2
        case .bottom:
            // When dragging bottom handle, top should stay fixed
            // So center moves down by half the height change
            positionAdjustment.y = normalizedHeightChange / 2
        case .leading:
            // When dragging left handle, right should stay fixed
            // So center moves left by half the width change
            positionAdjustment.x = -normalizedWidthChange / 2
        case .trailing:
            // When dragging right handle, left should stay fixed
            // So center moves right by half the width change
            positionAdjustment.x = normalizedWidthChange / 2
        }
        
        // Apply size changes
        circles[index].width = newWidth
        circles[index].height = newHeight
        
        // Apply position adjustment with bounds checking
        let newPosition = CGPoint(
            x: max(0, min(1, circle.position.x + positionAdjustment.x)),
            y: max(0, min(1, circle.position.y + positionAdjustment.y))
        )
        circles[index].position = newPosition
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
        isExporting = true
        
        let isPro = try? await storeManager.isProEnabled()

        if isPro ?? true {
            export()
        } else {
            isExporting = false
            storeManager.setPaywallSource(.exportAttempt)
            showPaywall = true
        }
    }

    func onHidePaywall() {
        isExporting = true
        export()
    }

    private func export() {
        guard let selectedImage else { 
            isExporting = false
            return 
        }
        
        Task {
            print("Exporting image...")
            
            // Resize image if longest side exceeds 2048px
            let imageToProcess = await resizeImageIfNeeded(selectedImage, maxSize: 5000)

            // Render the final image with blur effects on background thread
            let processedImage = await renderImageWithBlur(imageToProcess)
            
            await MainActor.run {
                if let processedImage = processedImage {
                    exportedImage = processedImage
                    showShareSheet = true
                }
                isExporting = false
            }
        }
    }

    private func renderImageWithBlur(_ originalImage: UIImage) async -> UIImage? {
        guard !circles.isEmpty else {
            // If no circles, return original image
            return originalImage
        }
        
        return await Task.detached { [weak self] in
            guard let self = self else { return originalImage }
            
            // First, create a blurred version of the entire image
            guard let blurredImage = self.createBlurredImage(originalImage) else {
                return originalImage
            }

            let imageSize = originalImage.size
            let format = UIGraphicsImageRendererFormat.default()
            format.scale = originalImage.scale
            let renderer = UIGraphicsImageRenderer(size: imageSize, format: format)
            
            return renderer.image { context in
            let cgContext = context.cgContext
            
            // Draw the original image as base
            originalImage.draw(at: .zero)
            
            // For each circle, draw the blurred version in that area
            for circle in self.circles {
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
        }.value
    }
    
    private func resizeImageIfNeeded(_ image: UIImage, maxSize: CGFloat) async -> UIImage {
        return await Task.detached {
            let currentSize = image.size
            let longestSide = max(currentSize.width, currentSize.height)
            
            // If longest side is already within limit, return original
            guard longestSide > maxSize else { return image }
            
            // Calculate scale factor to fit within maxSize
            let scaleFactor = maxSize / longestSide
            let newSize = CGSize(
                width: currentSize.width * scaleFactor,
                height: currentSize.height * scaleFactor
            )
            
            // Create resized image
            let format = UIGraphicsImageRendererFormat.default()
            format.scale = image.scale
            let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
            return renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: newSize))
            }
        }.value
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

    // MARK: - Memory Cleanup
    func cleanupExportedImage() {
        exportedImage = nil
    }
    
    // MARK: - Rating Request
    func handleSuccessfulExport() {
        print("🚀 EditorViewModel: handleSuccessfulExport() called")
        ratingRequestManager.recordExport()
    }
}
