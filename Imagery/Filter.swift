//
//  Filter.swift
//  Imagery
//
//  Created by Meniny on 2015/08/31.
//
//  Copyright (c) 2015 Meniny 
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.



import CoreImage
import Accelerate

// Reuse the same CI Context for all CI drawing.
private let ciContext = CIContext(options: nil)

/// ImageryCIImageTransformer method which will be used in to provide a `Filter`.
public typealias ImageryCIImageTransformer = (CIImage) -> CIImage?

/// Supply a filter to create an `ImageProcessor`.
public protocol CIImageProcessor: ImageProcessor {
    var filter: Filter { get }
}

extension CIImageProcessor {
    public func process(item: ImageProcessItem, options: ImageryOptionsInfo) -> ImageType? {
        switch item {
        case .image(let image):
            return image.imagery.apply(filter)
        case .data(_):
            return (DefaultImageProcessor.default >> self).process(item: item, options: options)
        }
    }
}

/// Wrapper for a `ImageryCIImageTransformer` of CIImage filters.
public struct Filter {
    
    let transform: ImageryCIImageTransformer

    public init(tranform: @escaping ImageryCIImageTransformer) {
        self.transform = tranform
    }
    
    /// Tint filter which will apply a tint color to images.
    public static var tint: (ColorType) -> Filter = {
        color in
        Filter { input in
            let colorFilter = CIFilter(name: "CIConstantColorGenerator")!
            colorFilter.setValue(CIColor(color: color), forKey: kCIInputColorKey)
            
            let colorImage = colorFilter.outputImage
            let filter = CIFilter(name: "CISourceOverCompositing")!
            filter.setValue(colorImage, forKey: kCIInputImageKey)
            filter.setValue(input, forKey: kCIInputBackgroundImageKey)
            return filter.outputImage?.cropping(to: input.extent)
        }
    }
    
    public typealias ColorElement = (CGFloat, CGFloat, CGFloat, CGFloat)
    
    /// ColorType control filter which will apply color control change to images.
    public static var colorControl: (ColorElement) -> Filter = {
        brightness, contrast, saturation, inputEV in
        Filter { input in
            let paramsColor = [kCIInputBrightnessKey: brightness,
                               kCIInputContrastKey: contrast,
                               kCIInputSaturationKey: saturation]
            
            let blackAndWhite = input.applyingFilter("CIColorControls", withInputParameters: paramsColor)
            let paramsExposure = [kCIInputEVKey: inputEV]
            return blackAndWhite.applyingFilter("CIExposureAdjust", withInputParameters: paramsExposure)
        }
        
    }
}

extension Imagery where Base: ImageType {
    /// Apply a `Filter` containing `CIImage` transformer to `self`.
    ///
    /// - parameter filter: The filter used to transform `self`.
    ///
    /// - returns: A transformed image by input `Filter`.
    ///
    /// - Note: Only CG-based images are supported. If any error happens during transforming, `self` will be returned.
    public func apply(_ filter: Filter) -> ImageType {
        
        guard let cgImage = cgImage else {
            assertionFailure("[Imagery] Tint image only works for CG-based image.")
            return base
        }
        
        let inputImage = CIImage(cgImage: cgImage)
        guard let outputImage = filter.transform(inputImage) else {
            return base
        }
        
        guard let result = ciContext.createCGImage(outputImage, from: outputImage.extent) else {
            assertionFailure("[Imagery] Can not make an tint image within context.")
            return base
        }
        
        #if os(macOS)
            return fixedForRetinaPixel(cgImage: result, to: size)
        #else
            return ImageType(cgImage: result, scale: base.scale, orientation: base.imageOrientation)
        #endif
    }

}
