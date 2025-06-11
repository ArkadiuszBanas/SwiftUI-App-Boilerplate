//
//  EditorView.swift
//  SwiftUI-App-Boilerplate
//
//  Created by Arek on 21/10/2023.
//

import SwiftUI
import PhotosUI

// MARK: - Blur Mask View
struct BlurMaskView: View {
    let circles: [EditableCircle]
    let imageSize: CGSize
    let imageScale: CGFloat
    let imageOffset: CGSize
    let containerSize: CGSize
    
    private func circleScreenPosition(for circle: EditableCircle) -> CGPoint {
        // Calculate the actual image size when scaled and fit to container
        let imageAspect = imageSize.width / imageSize.height
        let containerAspect = containerSize.width / containerSize.height
        
        let actualImageSize: CGSize
        if imageAspect > containerAspect {
            // Image is constrained by width
            actualImageSize = CGSize(
                width: containerSize.width,
                height: containerSize.width / imageAspect
            )
        } else {
            // Image is constrained by height
            actualImageSize = CGSize(
                width: containerSize.height * imageAspect,
                height: containerSize.height
            )
        }
        
        // Scale the image size by current scale
        let scaledImageSize = CGSize(
            width: actualImageSize.width * imageScale,
            height: actualImageSize.height * imageScale
        )
        
        // Calculate the image's top-left position in the container
        let imageTopLeft = CGPoint(
            x: (containerSize.width - scaledImageSize.width) / 2 + imageOffset.width,
            y: (containerSize.height - scaledImageSize.height) / 2 + imageOffset.height
        )
        
        // Convert normalized position to screen position
        return CGPoint(
            x: imageTopLeft.x + (circle.position.x * scaledImageSize.width),
            y: imageTopLeft.y + (circle.position.y * scaledImageSize.height)
        )
    }
    
    var body: some View {
        ZStack {
            // Transparent background
            Color.clear
            
            // Create circles for masking
            ForEach(circles) { circle in
                let screenPosition = circleScreenPosition(for: circle)
                let scaledWidth = circle.width * imageScale
                let scaledHeight = circle.height * imageScale
                
                Ellipse()
                    .fill(Color.white)
                    .frame(width: scaledWidth, height: scaledHeight)
                    .position(x: screenPosition.x, y: screenPosition.y)
            }
        }
    }
}

// MARK: - Blurred Image View
struct BlurredImageView: View {
    let image: UIImage
    let circles: [EditableCircle]
    let imageSize: CGSize
    @Binding var imageScale: CGFloat
    @Binding var imageOffset: CGSize
    
    var body: some View {
        GeometryReader { geometry in
            ZoomableImageView(
                image: image,
                scale: $imageScale,
                offset: $imageOffset,
                onReset: {}
            )
            .blur(radius: 10)
            .mask(
                BlurMaskView(
                    circles: circles,
                    imageSize: imageSize,
                    imageScale: imageScale,
                    imageOffset: imageOffset,
                    containerSize: geometry.size
                )
            )
        }
    }
}

// MARK: - Movable Circle View
struct MovableCircleView: View {
    let circle: EditableCircle
    let imageSize: CGSize
    let imageScale: CGFloat
    let imageOffset: CGSize
    let containerSize: CGSize
    let onPositionChange: (EditableCircle, CGPoint) -> Void
    let onRemove: (EditableCircle) -> Void
    
    @State private var dragOffset: CGSize = .zero
    
    private func circleScreenPosition() -> CGPoint {
        // Calculate the actual image size when scaled and fit to container
        let imageAspect = imageSize.width / imageSize.height
        let containerAspect = containerSize.width / containerSize.height
        
        let actualImageSize: CGSize
        if imageAspect > containerAspect {
            // Image is constrained by width
            actualImageSize = CGSize(
                width: containerSize.width,
                height: containerSize.width / imageAspect
            )
        } else {
            // Image is constrained by height
            actualImageSize = CGSize(
                width: containerSize.height * imageAspect,
                height: containerSize.height
            )
        }
        
        // Scale the image size by current scale
        let scaledImageSize = CGSize(
            width: actualImageSize.width * imageScale,
            height: actualImageSize.height * imageScale
        )
        
        // Calculate the image's top-left position in the container
        let imageTopLeft = CGPoint(
            x: (containerSize.width - scaledImageSize.width) / 2 + imageOffset.width,
            y: (containerSize.height - scaledImageSize.height) / 2 + imageOffset.height
        )
        
        // Convert normalized position to screen position
        return CGPoint(
            x: imageTopLeft.x + (circle.position.x * scaledImageSize.width),
            y: imageTopLeft.y + (circle.position.y * scaledImageSize.height)
        )
    }
    
    private func updateCirclePosition(from screenPosition: CGPoint) {
        // Calculate the actual image size when scaled and fit to container
        let imageAspect = imageSize.width / imageSize.height
        let containerAspect = containerSize.width / containerSize.height
        
        let actualImageSize: CGSize
        if imageAspect > containerAspect {
            actualImageSize = CGSize(
                width: containerSize.width,
                height: containerSize.width / imageAspect
            )
        } else {
            actualImageSize = CGSize(
                width: containerSize.height * imageAspect,
                height: containerSize.height
            )
        }
        
        let scaledImageSize = CGSize(
            width: actualImageSize.width * imageScale,
            height: actualImageSize.height * imageScale
        )
        
        let imageTopLeft = CGPoint(
            x: (containerSize.width - scaledImageSize.width) / 2 + imageOffset.width,
            y: (containerSize.height - scaledImageSize.height) / 2 + imageOffset.height
        )
        
        // Convert screen position back to normalized position
        let normalizedX = (screenPosition.x - imageTopLeft.x) / scaledImageSize.width
        let normalizedY = (screenPosition.y - imageTopLeft.y) / scaledImageSize.height
        
        // Clamp to image bounds
        let clampedPosition = CGPoint(
            x: max(0, min(1, normalizedX)),
            y: max(0, min(1, normalizedY))
        )
        
        onPositionChange(circle, clampedPosition)
    }
    
    var body: some View {
        let screenPosition = circleScreenPosition()
        let scaledWidth = circle.width * imageScale
        let scaledHeight = circle.height * imageScale
        
        Ellipse()
            .stroke(Color.white, lineWidth: 2)
            .fill(.white.opacity(0.01))
            .frame(width: scaledWidth, height: scaledHeight)
            .position(x: screenPosition.x, y: screenPosition.y)
            .offset(dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        let finalPosition = CGPoint(
                            x: screenPosition.x + value.translation.width,
                            y: screenPosition.y + value.translation.height
                        )
                        updateCirclePosition(from: finalPosition)
                        dragOffset = .zero
                    }
            )
            .onTapGesture(count: 2) {
                withAnimation(.spring()) {
                    onRemove(circle)
                }
            }
            .accessibilityLabel("Blur ellipse")
            .accessibilityHint("Drag to move, double tap to remove")
    }
}

// MARK: - Circle Overlay View
struct CircleOverlayView: View {
    let circles: [EditableCircle]
    let imageSize: CGSize
    let imageScale: CGFloat
    let imageOffset: CGSize
    let onPositionChange: (EditableCircle, CGPoint) -> Void
    let onRemove: (EditableCircle) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(circles) { circle in
                MovableCircleView(
                    circle: circle,
                    imageSize: imageSize,
                    imageScale: imageScale,
                    imageOffset: imageOffset,
                    containerSize: geometry.size,
                    onPositionChange: onPositionChange,
                    onRemove: onRemove
                )
            }
        }
    }
}

struct EditorView: View {
    @State private var viewModel: EditorViewModel
    
    init(viewModel: EditorViewModel = EditorViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            // Background color
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Image Display Area
            if let selectedImage = viewModel.selectedImage {
                ZStack {
                    // Base image layer
                    ZoomableImageView(
                        image: selectedImage,
                        scale: $viewModel.imageScale,
                        offset: $viewModel.imageOffset,
                        onReset: viewModel.resetZoom
                    )
                    
                    // Blurred image layer with circle masks
                    BlurredImageView(
                        image: selectedImage,
                        circles: viewModel.circles,
                        imageSize: selectedImage.size,
                        imageScale: $viewModel.imageScale,
                        imageOffset: $viewModel.imageOffset
                    )
                    
                    // Interactive circle overlay
                    CircleOverlayView(
                        circles: viewModel.circles,
                        imageSize: selectedImage.size,
                        imageScale: viewModel.imageScale,
                        imageOffset: viewModel.imageOffset,
                        onPositionChange: viewModel.updateCirclePosition,
                        onRemove: viewModel.removeCircle
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            } else {
                // Placeholder when no image is selected
                VStack {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No image selected")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Tap 'Load Photo' to get started")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Bottom Toolbar
            VStack {
                Spacer()
                
                HStack(spacing: 0) {
                    // Load Photo
                    PhotosPicker(selection: $viewModel.selectedPhoto, matching: .images) {
                        VStack(spacing: 4) {
                            Image(systemName: "photo")
                                .font(.system(size: 24))
                            Text("Load Photo")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .accessibilityLabel("Load Photo")
                    .accessibilityHint("Opens photo gallery to select an image")
                    
                    // Auto Detect Faces
                    Button {
                        Task {
                            await viewModel.detectFaces()
                        }
                    } label: {
                        VStack(spacing: 4) {
                            ZStack {
                                Image(systemName: "face.dashed")
                                    .font(.system(size: 24))
                                
                                if viewModel.isDetectingFaces {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                            }
                            Text("Detect Faces")
                                .font(.caption)
                        }
                        .foregroundColor(viewModel.selectedImage == nil ? .gray : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .disabled(viewModel.selectedImage == nil || viewModel.isDetectingFaces)
                    .accessibilityLabel("Auto Detect Faces")
                    .accessibilityHint("Automatically detects faces in the selected image")
                    
                    // Add Shape
                    Button {
                        viewModel.addShape()
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "drop")
                                .font(.system(size: 24))
                            Text("Add Blur")
                                .font(.caption)
                        }
                        .foregroundColor(viewModel.selectedImage == nil ? .gray : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .disabled(viewModel.selectedImage == nil)
                    .accessibilityLabel("Add Blur")
                    .accessibilityHint("Adds a movable ellipse to blur areas of the image")
                    
                    // Export
                    Button {
                        viewModel.exportImage()
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 24))
                            Text("Export")
                                .font(.caption)
                        }
                        .foregroundColor(viewModel.selectedImage == nil ? .gray : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .disabled(viewModel.selectedImage == nil)
                    .accessibilityLabel("Export Image")
                    .accessibilityHint("Saves the edited image to your photo library")
                }
                .background(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .environment(\.colorScheme, .dark)
                )
                .edgesIgnoringSafeArea(.bottom)
            }
        }
        .onChange(of: viewModel.selectedPhoto) { _, _ in
            Task {
                await viewModel.loadImage()
            }
        }
    }
}

#Preview {
    EditorView()
} 
