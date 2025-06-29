//
//  EditorView.swift
//  BlurFace
//
//  Created by Arek on 21/10/2023.
//

import SwiftUI
import PhotosUI
import RevenueCatUI

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
                        onSizeAndPositionChange: viewModel.updateCircleSizeAndPosition,
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
                EmptyStateView()
            }
            
            // Bottom Toolbar
            VStack {
                Spacer()
                
                BottomToolbar(
                    selectedPhoto: $viewModel.selectedPhoto,
                    selectedImage: viewModel.selectedImage,
                    isExporting: viewModel.isExporting,
                    onAddShape: viewModel.addShape,
                    onExport: {
                        Task {
                            await viewModel.onTapExportImage()
                        }
                    }
                )
            }
        }
        .onChange(of: viewModel.selectedPhoto) { _, _ in
            Task {
                await viewModel.loadImage()
            }
        }
        .sheet(isPresented: $viewModel.showShareSheet, onDismiss: {
            // Clean up exported image when share sheet is dismissed to free memory
            viewModel.cleanupExportedImage()
        }) {
            if let exportedImage = viewModel.exportedImage {
                ShareSheet(
                    activityItems: [exportedImage],
                    onCompletion: { activityType, completed in
                        print("📤 ShareSheet onCompletion called:")
                        print("   Activity type: \(String(describing: activityType))")
                        print("   Completed: \(completed)")
                        if completed {
                            viewModel.handleSuccessfulExport()
                        }
                    }
                )
            }
        }
        .sheet(isPresented: $viewModel.showPaywall) {
            PaywallView()
                .onDisappear() {
                    viewModel.onHidePaywall()
                }
        }
    }
}

#Preview {
    EditorView()
}
