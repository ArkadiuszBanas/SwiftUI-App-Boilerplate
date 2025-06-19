//
//  ZoomableImageView.swift
//  BlurFace
//
//  Created by Arek on 21/10/2023.
//

import SwiftUI

struct ZoomableImageView: View {
    let image: UIImage
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    let onReset: () -> Void
    
    @State private var lastOffset: CGSize = .zero
    
    private func calculateMinScale(for size: CGSize) -> CGFloat {
        let imageAspect = image.size.width / image.size.height
        let screenAspect = size.width / size.height
        
        if imageAspect > screenAspect {
            // Image is wider than screen
            return size.width / image.size.width
        } else {
            // Image is taller than screen
            return size.height / image.size.height
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let minScale = calculateMinScale(for: geometry.size)
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(scale)
                .offset(offset)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .gesture(
                    SimultaneousGesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let newScale = max(minScale, min(value, 4.0))
                                if newScale < scale {
                                    // If zooming out and below min scale, reset
                                    withAnimation(.spring()) {
                                        scale = 1.0
                                        offset = .zero
                                        lastOffset = .zero
                                    }
                                } else {
                                    scale = newScale
                                }
                            },
                        DragGesture()
                            .onChanged { value in
                                offset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                            }
                            .onEnded { value in
                                // Update lastOffset to current position
                                lastOffset = offset
                                
                                // Snap back to bounds if needed
                                withAnimation(.spring()) {
                                    let maxOffset = max(0, (geometry.size.width * scale - geometry.size.width) / 2)
                                    offset.width = max(-maxOffset, min(maxOffset, offset.width))
                                    
                                    let maxVerticalOffset = max(0, (geometry.size.height * scale - geometry.size.height) / 2)
                                    offset.height = max(-maxVerticalOffset, min(maxVerticalOffset, offset.height))
                                    
                                    // Update lastOffset to the constrained position
                                    lastOffset = offset
                                }
                            }
                    )
                )
                .onTapGesture(count: 2) {
                    withAnimation(.spring()) {
                        onReset()
                        lastOffset = .zero
                    }
                }
                .accessibilityLabel("Selected Photo")
                .accessibilityHint("Pinch to zoom, drag to pan, double tap to reset zoom")
        }
    }
} 