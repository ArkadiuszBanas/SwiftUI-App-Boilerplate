//
//  ResizeHandleView.swift
//  BlurFace
//
//  Created by Arek on 21/10/2023.
//

import SwiftUI

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
    let imageSize: CGSize
    let containerSize: CGSize
    let onSizeAndPositionChange: (EditableCircle, CGFloat, CGFloat, HandlePosition, CGSize, CGFloat, CGSize) -> Void
    
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
            .font(.system(size: 20))
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
                        
                        onSizeAndPositionChange(circle, newWidth, newHeight, position, imageSize, imageScale, containerSize)
                        dragOffset = .zero
                    }
            )
            .accessibilityLabel(NSLocalizedString("editor.resize_handle_label", comment: ""))
            .accessibilityHint(NSLocalizedString("editor.resize_handle_hint", comment: ""))
    }
} 