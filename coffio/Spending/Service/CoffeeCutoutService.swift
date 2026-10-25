//
//  CoffeeCutoutService.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/10/26.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI
import Vision

class CoffeeCutoutService {
    private static let context = CIContext()
    private static let standardCanvasSize = CGSize(width: 512, height: 512)

    static func removeBackground(from inputImage: UIImage) async -> UIImage? {
        let fixedImage = inputImage.fixedOrientation()
        guard let ciImage = CIImage(image: fixedImage) else { return nil }

        let cgOrientation = CGImagePropertyOrientation(fixedImage.imageOrientation)
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: cgOrientation)

        do {
            try handler.perform([request])
            guard let result = request.results?.first else { return nil }

            let maskPixelBuffer = try result.generateScaledMaskForImage(
                forInstances: result.allInstances,
                from: handler
            )
            let maskImage = CIImage(cvPixelBuffer: maskPixelBuffer)

            let blendFilter = CIFilter.blendWithMask()
            blendFilter.inputImage = ciImage
            blendFilter.maskImage = maskImage
            blendFilter.backgroundImage = CIImage.empty()

            guard let outputCIImage = blendFilter.outputImage,
                let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent)
            else { return nil }

            let rawCutout = UIImage(cgImage: cgImage, scale: fixedImage.scale, orientation: .up)
            
            // Standardize into a uniform canvas size while preserving aspect ratio
            return standardize(rawCutout, targetSize: standardCanvasSize)
        } catch {
            print("Background removal failed: \(error.localizedDescription)")
            return nil
        }
    }

    private static func standardize(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0 // Standardized scale
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)

        return renderer.image { _ in
            let imageSize = image.size
            guard imageSize.width > 0, imageSize.height > 0 else { return }

            // Calculate aspect fit scale factor
            let widthRatio = targetSize.width / imageSize.width
            let heightRatio = targetSize.height / imageSize.height
            let scaleFactor = min(widthRatio, heightRatio)

            let scaledWidth = imageSize.width * scaleFactor
            let scaledHeight = imageSize.height * scaleFactor

            // Center the image inside the target canvas
            let x = (targetSize.width - scaledWidth) / 2
            let y = (targetSize.height - scaledHeight) / 2

            let drawRect = CGRect(x: x, y: y, width: scaledWidth, height: scaledHeight)
            image.draw(in: drawRect)
        }
    }
}
