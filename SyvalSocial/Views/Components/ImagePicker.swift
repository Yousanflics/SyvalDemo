import SwiftUI
import PhotosUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 5 // Allow up to 5 images
        config.preferredAssetRepresentationMode = .current
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            let group = DispatchGroup()
            var selectedImages: [UIImage] = []
            
            for result in results {
                group.enter()
                
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                        defer { group.leave() }
                        
                        if let image = image as? UIImage {
                            DispatchQueue.main.async {
                                selectedImages.append(image)
                            }
                        }
                    }
                } else {
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.parent.selectedImages = selectedImages
            }
        }
    }
}

// Helper extension to compress images for upload
extension UIImage {
    func compressed(to maxSizeKB: Int = 500) -> Data? {
        var compressionQuality: CGFloat = 1.0
        let maxSize = maxSizeKB * 1024
        
        guard var imageData = self.jpegData(compressionQuality: compressionQuality) else {
            return nil
        }
        
        while imageData.count > maxSize && compressionQuality > 0.1 {
            compressionQuality -= 0.1
            if let compressedData = self.jpegData(compressionQuality: compressionQuality) {
                imageData = compressedData
            }
        }
        
        return imageData
    }
    
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        self.draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
} 
