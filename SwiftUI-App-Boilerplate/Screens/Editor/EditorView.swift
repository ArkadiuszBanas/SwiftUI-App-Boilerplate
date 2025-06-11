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

// MARK: - Resize Handle View
struct ResizeHandleView: View {
    enum HandlePosition {
        case top, bottom, leading, trailing
    }
    
    let position: HandlePosition
    let centerPosition: CGPoint
    let width: CGFloat
    let height: CGFloat
    let circle: EditableCircle
    let imageScale: CGFloat
    let onSizeChange: (EditableCircle, CGFloat, CGFloat) -> Void
    
    @State private var dragOffset: CGSize = .zero
    
    private var handlePosition: CGPoint {
        switch position {
        case .top:
            return CGPoint(x: centerPosition.x, y: centerPosition.y - height/2)
        case .bottom:
            return CGPoint(x: centerPosition.x, y: centerPosition.y + height/2)
        case .leading:
            return CGPoint(x: centerPosition.x - width/2, y: centerPosition.y)
        case .trailing:
            return CGPoint(x: centerPosition.x + width/2, y: centerPosition.y)
        }
    }
    
    var body: some View {
        Image(systemName: "plus.circle.fill")
            .font(.system(size: 16))
            .foregroundColor(.white)
            .background(Circle().fill(Color.black.opacity(0.3)))
            .position(x: handlePosition.x, y: handlePosition.y)
            .offset(dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        let translation = value.translation
                        
                        // Calculate new dimensions based on handle position and drag distance
                        var newWidth = circle.width
                        var newHeight = circle.height
                        
                        switch position {
                        case .top:
                            newHeight = circle.height - (translation.height / imageScale)
                        case .bottom:
                            newHeight = circle.height + (translation.height / imageScale)
                        case .leading:
                            newWidth = circle.width - (translation.width / imageScale)
                        case .trailing:
                            newWidth = circle.width + (translation.width / imageScale)
                        }
                        
                        onSizeChange(circle, newWidth, newHeight)
                        dragOffset = .zero
                    }
            )
            .accessibilityLabel("Resize handle")
            .accessibilityHint("Drag to resize the blur ellipse")
    }
}

// MARK: - Movable Circle View
struct MovableCircleView: View {
    let circle: EditableCircle
    let imageSize: CGSize
    let imageScale: CGFloat
    let imageOffset: CGSize
    let containerSize: CGSize
    let isSelected: Bool
    let onPositionChange: (EditableCircle, CGPoint) -> Void
    let onSizeChange: (EditableCircle, CGFloat, CGFloat) -> Void
    let onRemove: (EditableCircle) -> Void
    let onSelect: (EditableCircle) -> Void
    let onDeselect: () -> Void
    
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
        
        ZStack {
            // Main ellipse
            Ellipse()
                .stroke(isSelected ? Color.white : Color.clear, lineWidth: isSelected ? 2 : 0)
                .fill(.white.opacity(0.01))
                .frame(width: scaledWidth, height: scaledHeight)
                .position(x: screenPosition.x, y: screenPosition.y)
                .offset(dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if isSelected {
                                dragOffset = value.translation
                            }
                        }
                        .onEnded { value in
                            if isSelected {
                                let finalPosition = CGPoint(
                                    x: screenPosition.x + value.translation.width,
                                    y: screenPosition.y + value.translation.height
                                )
                                updateCirclePosition(from: finalPosition)
                                dragOffset = .zero
                            }
                        }
                )
                .onTapGesture {
                    if isSelected {
                        onDeselect()
                    } else {
                        onSelect(circle)
                    }
                }
                .onTapGesture(count: 2) {
                    withAnimation(.spring()) {
                        onRemove(circle)
                    }
                }
                .accessibilityLabel("Blur ellipse")
                .accessibilityHint("Tap to select, drag to move when selected, double tap to remove")
            
            // Resize handles (only show when selected)
            if isSelected {
                ResizeHandleView(
                    position: .top,
                    centerPosition: screenPosition,
                    width: scaledWidth,
                    height: scaledHeight,
                    circle: circle,
                    imageScale: imageScale,
                    onSizeChange: onSizeChange
                )
                
                ResizeHandleView(
                    position: .bottom,
                    centerPosition: screenPosition,
                    width: scaledWidth,
                    height: scaledHeight,
                    circle: circle,
                    imageScale: imageScale,
                    onSizeChange: onSizeChange
                )
                
                ResizeHandleView(
                    position: .leading,
                    centerPosition: screenPosition,
                    width: scaledWidth,
                    height: scaledHeight,
                    circle: circle,
                    imageScale: imageScale,
                    onSizeChange: onSizeChange
                )
                
                ResizeHandleView(
                    position: .trailing,
                    centerPosition: screenPosition,
                    width: scaledWidth,
                    height: scaledHeight,
                    circle: circle,  
                    imageScale: imageScale,
                    onSizeChange: onSizeChange
                )
            }
        }
    }
}

// MARK: - Circle Overlay View
struct CircleOverlayView: View {
    let circles: [EditableCircle]
    let imageSize: CGSize
    let imageScale: CGFloat
    let imageOffset: CGSize
    let selectedCircleId: UUID?
    let onPositionChange: (EditableCircle, CGPoint) -> Void
    let onSizeChange: (EditableCircle, CGFloat, CGFloat) -> Void
    let onRemove: (EditableCircle) -> Void
    let onSelect: (EditableCircle) -> Void
    let onDeselect: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(circles) { circle in
                MovableCircleView(
                    circle: circle,
                    imageSize: imageSize,
                    imageScale: imageScale,
                    imageOffset: imageOffset,
                    containerSize: geometry.size,
                    isSelected: selectedCircleId == circle.id,
                    onPositionChange: onPositionChange,
                    onSizeChange: onSizeChange,
                    onRemove: onRemove,
                    onSelect: onSelect,
                    onDeselect: onDeselect
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
            Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)

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
                        selectedCircleId: viewModel.selectedCircleId,
                        onPositionChange: viewModel.updateCirclePosition,
                        onSizeChange: viewModel.updateCircleSize,
                        onRemove: viewModel.removeCircle,
                        onSelect: viewModel.selectCircle,
                        onDeselect: viewModel.deselectCircle
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    // Deselect all circles when tapping empty space
                    viewModel.deselectCircle()
                }
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
                
                BottomToolbar(
                    selectedPhoto: $viewModel.selectedPhoto,
                    selectedImage: viewModel.selectedImage,
                    isDetectingFaces: viewModel.isDetectingFaces,
                    onDetectFaces: viewModel.detectFaces,
                    onAddShape: viewModel.addShape,
                    onExport: viewModel.exportImage
                )
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
