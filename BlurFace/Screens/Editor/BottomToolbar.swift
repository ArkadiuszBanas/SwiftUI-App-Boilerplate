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
                    Text(NSLocalizedString("toolbar.load_photo", comment: ""))
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .accessibilityLabel(NSLocalizedString("toolbar.load_photo", comment: ""))
            .accessibilityHint(NSLocalizedString("toolbar.load_photo_hint", comment: ""))
            
            if selectedImage != nil {
                // Add Shape
                Button {
                    onAddShape()
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "drop")
                            .font(.system(size: 24))
                        Text(NSLocalizedString("toolbar.add_blur", comment: ""))
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .accessibilityLabel(NSLocalizedString("toolbar.add_blur", comment: ""))
                .accessibilityHint(NSLocalizedString("toolbar.add_blur_hint", comment: ""))
                
                // Export
                if isExporting {
                    VStack(spacing: 4) {
                        ProgressView()
                            .tint(.gray)
                            .scaleEffect(1.2)
                        Text(NSLocalizedString("toolbar.exporting", comment: ""))
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .accessibilityLabel(NSLocalizedString("toolbar.export_label", comment: ""))
                    .accessibilityHint(NSLocalizedString("toolbar.exporting_hint", comment: ""))
                } else {
                    Button {
                        onExport()
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 24))
                            Text(NSLocalizedString("toolbar.export", comment: ""))
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .accessibilityLabel(NSLocalizedString("toolbar.export_label", comment: ""))
                    .accessibilityHint(NSLocalizedString("toolbar.export_hint", comment: ""))
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
