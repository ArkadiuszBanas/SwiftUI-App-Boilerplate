//
//  MovableCircleView.swift
//  BlurFace
//
//  Created by Arek on 21/10/2023.
//

import SwiftUI

struct MovableCircleView: View {
    let circle: EditableCircle
    let imageSize: CGSize
    let imageScale: CGFloat
    let imageOffset: CGSize
    let containerSize: CGSize
    let isSelected: Bool
    let onPositionChange: (EditableCircle, CGPoint) -> Void
    let onSizeAndPositionChange: (EditableCircle, CGFloat, CGFloat, ResizeHandleView.HandlePosition, CGSize, CGFloat, CGSize) -> Void
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
                .accessibilityLabel(NSLocalizedString("editor.blur_ellipse_label", comment: ""))
                .accessibilityHint(NSLocalizedString("editor.blur_ellipse_hint", comment: ""))
            
            // Resize handles (only show when selected)
            if isSelected {
                ResizeHandleView(
                    position: .top,
                    centerPosition: screenPosition,
                    width: scaledWidth,
                    height: scaledHeight,
                    circle: circle,
                    imageScale: imageScale,
                    imageSize: imageSize,
                    containerSize: containerSize,
                    onSizeAndPositionChange: onSizeAndPositionChange
                )
                
                ResizeHandleView(
                    position: .bottom,
                    centerPosition: screenPosition,
                    width: scaledWidth,
                    height: scaledHeight,
                    circle: circle,
                    imageScale: imageScale,
                    imageSize: imageSize,
                    containerSize: containerSize,
                    onSizeAndPositionChange: onSizeAndPositionChange
                )
                
                ResizeHandleView(
                    position: .leading,
                    centerPosition: screenPosition,
                    width: scaledWidth,
                    height: scaledHeight,
                    circle: circle,
                    imageScale: imageScale,
                    imageSize: imageSize,
                    containerSize: containerSize,
                    onSizeAndPositionChange: onSizeAndPositionChange
                )
                
                ResizeHandleView(
                    position: .trailing,
                    centerPosition: screenPosition,
                    width: scaledWidth,
                    height: scaledHeight,
                    circle: circle,
                    imageScale: imageScale,
                    imageSize: imageSize,
                    containerSize: containerSize,
                    onSizeAndPositionChange: onSizeAndPositionChange
                )
            }
        }
    }
} 