//
//  CircleOverlayView.swift
//  BlurFace
//
//  Created by Arek on 21/10/2023.
//

import SwiftUI

struct CircleOverlayView: View {
    let circles: [EditableCircle]
    let imageSize: CGSize
    let imageScale: CGFloat
    let imageOffset: CGSize
    let selectedCircleId: UUID?
    let onPositionChange: (EditableCircle, CGPoint) -> Void
    let onSizeAndPositionChange: (EditableCircle, CGFloat, CGFloat, ResizeHandleView.HandlePosition, CGSize, CGFloat, CGSize) -> Void
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
                    onSizeAndPositionChange: { circle, width, height, position, imageSize, imageScale, _ in
                        onSizeAndPositionChange(circle, width, height, position, imageSize, imageScale, geometry.size)
                    },
                    onRemove: onRemove,
                    onSelect: onSelect,
                    onDeselect: onDeselect
                )
            }
        }
    }
} 