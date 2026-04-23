//
//  ImageConverter.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 23/04/26.
//

import Foundation
import SwiftUI

extension Image {
    @MainActor
    func asUIImage() -> UIImage? {
        let controller = UIHostingController(
            rootView: self
                .resizable()
                .scaledToFit()
        )
        
        let view = controller.view
        let targetSize = CGSize(width: 1000, height: 1000)
        
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            view?.drawHierarchy(
                in: view?.bounds ?? .zero,
                afterScreenUpdates: true
            )
        }
    }
}
