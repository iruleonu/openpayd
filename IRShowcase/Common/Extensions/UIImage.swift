//
//  UIImage.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 01/06/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import UIKit
import CoreImage
import Accelerate

extension UIImage {
    public func image(alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: .zero, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    public func apply(tintColor: UIColor?, maskImage: UIImage? = nil) -> UIImage? {
        // Check pre-conditions.
        if size.width < 1 || size.height < 1 {
            print("*** error: invalid size: \(size.width) x \(size.height). Both dimensions must be >= 1: \(self)")
            return nil
        }
        guard let cgImage = self.cgImage else {
            print("*** error: image must be backed by a CGImage: \(self)")
            return nil
        }
        if let mImage = maskImage, mImage.cgImage == nil {
            print("*** error: maskImage must be backed by a CGImage: \(mImage)")
            return nil
        }
        
        let screenScale = UIScreen.main.scale
        let imageRect = CGRect(origin: CGPoint.zero, size: size)
        
        UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
        guard let effectInContext = UIGraphicsGetCurrentContext() else { return  nil }
        
        effectInContext.scaleBy(x: 1.0, y: -1.0)
        effectInContext.translateBy(x: 0, y: -size.height)
        effectInContext.draw(cgImage, in: imageRect)
        
        var effectInBuffer = createEffectBuffer(effectInContext)
        
        UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
        
        guard let effectOutContext = UIGraphicsGetCurrentContext() else { return  nil }
        var effectOutBuffer = createEffectBuffer(effectOutContext)
        
        let divisor: CGFloat = 256
        let matrixSize = floatingPointSaturationMatrix.count
        var saturationMatrix = [Int16](repeating: 0, count: matrixSize)
        
        for i: Int in 0 ..< matrixSize {
            saturationMatrix[i] = Int16(round(floatingPointSaturationMatrix[i] * divisor))
        }
        
        vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, Int32(divisor), nil, nil, vImage_Flags(kvImageNoFlags))
        
        UIGraphicsEndImageContext()
        
        // Set up output context.
        UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
        
        guard let outputContext = UIGraphicsGetCurrentContext() else { return nil }
        
        outputContext.scaleBy(x: 1.0, y: -1.0)
        outputContext.translateBy(x: 0, y: -size.height)
        
        // Draw base image.
        outputContext.draw(cgImage, in: imageRect)
        
        // Add in color tint.
        if let color = tintColor {
            outputContext.saveGState()
            outputContext.setFillColor(color.cgColor)
            outputContext.fill(imageRect)
            outputContext.restoreGState()
        }
        
        // Output image is ready.
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return outputImage
    }
    
    private var floatingPointSaturationMatrix: [CGFloat] {
        return [
            0.0722, 0.0722, 0.0722, 0,
            0.7152, 0.7152, 0.7152, 0,
            0.2126, 0.2126, 0.2126, 0,
            0, 0, 0, 1
        ]
    }
    
    private func createEffectBuffer(_ context: CGContext) -> vImage_Buffer {
        let data = context.data
        let width = vImagePixelCount(context.width)
        let height = vImagePixelCount(context.height)
        let rowBytes = context.bytesPerRow
        
        return vImage_Buffer(data: data, height: height, width: width, rowBytes: rowBytes)
    }
}
