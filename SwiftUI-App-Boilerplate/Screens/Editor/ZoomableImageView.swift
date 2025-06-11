//
//  ZoomableImageView.swift
//  SwiftUI-App-Boilerplate
//
//  Created by Arek on 21/10/2023.
//

import SwiftUI

struct ZoomableImageView: View {
    let image: UIImage
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    let onReset: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    SimultaneousGesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = max(0.5, min(value, 5.0))
                            },
                        DragGesture()
                            .onChanged { value in
                                offset = value.translation
                            }
                            .onEnded { _ in
                                // Snap back to bounds if needed
                                withAnimation(.spring()) {
                                    let maxOffset = max(0, (geometry.size.width * scale - geometry.size.width) / 2)
                                    offset.width = max(-maxOffset, min(maxOffset, offset.width))
                                    
                                    let maxVerticalOffset = max(0, (geometry.size.height * scale - geometry.size.height) / 2)
                                    offset.height = max(-maxVerticalOffset, min(maxVerticalOffset, offset.height))
                                }
                            }
                    )
                )
                .onTapGesture(count: 2) {
                    withAnimation(.spring()) {
                        onReset()
                    }
                }
                .accessibilityLabel("Selected Photo")
                .accessibilityHint("Pinch to zoom, drag to pan, double tap to reset zoom")
        }
    }
} 