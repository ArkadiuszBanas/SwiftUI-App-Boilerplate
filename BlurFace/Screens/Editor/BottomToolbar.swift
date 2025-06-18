import SwiftUI
import PhotosUI

struct BottomToolbar: View {
    @Binding var selectedPhoto: PhotosPickerItem?
    let selectedImage: UIImage?
    let isExporting: Bool
    let onAddShape: () -> Void
    let onExport: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Load Photo
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                VStack(spacing: 4) {
                    Image(systemName: "photo")
                        .font(.system(size: 24))
                    Text("Load Photo")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .accessibilityLabel("Load Photo")
            .accessibilityHint("Opens photo gallery to select an image")
            
            if selectedImage != nil {
                // Add Shape
                Button {
                    onAddShape()
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "drop")
                            .font(.system(size: 24))
                        Text("Add Blur")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .accessibilityLabel("Add Blur")
                .accessibilityHint("Adds a movable ellipse to blur areas of the image")
                
                // Export
                if isExporting {
                    VStack(spacing: 4) {
                        ProgressView()
                            .tint(.gray)
                            .scaleEffect(1.2)
                        Text("Exporting")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .accessibilityLabel("Exporting Image")
                    .accessibilityHint("Image is currently being processed")
                } else {
                    Button {
                        onExport()
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 24))
                            Text("Export")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .accessibilityLabel("Export Image")
                    .accessibilityHint("Saves the edited image to your photo library")
                }
            }
        }
        .foregroundColor(.gray)
        .background(
            Rectangle()
                .fill(.black)
                .fill(.ultraThickMaterial)
                .cornerRadius(50)
        )
        .padding(.horizontal)
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    ZStack {
        Color(.systemGroupedBackground)

        BottomToolbar(
            selectedPhoto: .constant(nil),
            selectedImage: UIImage(named: "test"),
            isExporting: false,
            onAddShape: {},
            onExport: {}
        )
    }
}
