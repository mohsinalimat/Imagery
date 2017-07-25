//
//  ImageViewType+Imagery.swift
//  Imagery
//
//  Created by Meniny on 15/4/6.
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


#if os(macOS)
import AppKit
#else
import UIKit
#endif

// MARK: - Extension methods.
/**
 *	Set image to use from web.
 */
extension Imagery where Base: ImageViewType {
    /**
     Set an image with a resource, a placeholder image, options, progress handler and completion handler.
     
     - parameter resource:          ImageryResource object contains information such as `cacheKey` and `downloadURL`.
     - parameter placeholder:       A placeholder image when retrieving the image at URL.
     - parameter options:           A dictionary could control some behaviors. See `ImageryOptionsInfo` for more.
     - parameter progressBlock:     Called when the image downloading progress gets updated.
     - parameter completionHandler: Called when the image retrieved and set.
     
     - returns: A task represents the retrieving process.
     
     - note: Both the `progressBlock` and `completionHandler` will be invoked in main thread.
     The `CallbackDispatchQueue` specified in `optionsInfo` will not be used in callbacks of this method.
     
     If `resource` is `nil`, the `placeholder` image will be set and
     `completionHandler` will be called with both `error` and `image` being `nil`.
     */
    @discardableResult
    public func setImage(with resource: ImageryResource?,
                         placeholder: ImageType?,
                         options: ImageryOptionsInfo? = nil,
                         progressBlock: ImageryDownloadProgressBlock? = nil,
                         completionHandler: ImageryCompletionHandler? = nil) -> ImageryRetrieveImageTask {
        guard let resource = resource else {
            base.image = placeholder
            setWebURL(nil)
            completionHandler?(nil, nil, .none, nil)
            return .empty
        }
        
        var options = ImageryManager.shared.defaultOptions + (options ?? ImageryEmptyOptionsInfo)
        
        if !options.keepCurrentImageWhileLoading {
            base.image = placeholder
        }

        let maybeIndicator = indicator
        maybeIndicator?.startAnimatingView()
        
        setWebURL(resource.downloadURL)

        if base.shouldPreloadAllAnimation() {
            options.append(.preloadAllAnimationData)
        }
        
        let task = ImageryManager.shared.retrieveImage(
            with: resource,
            options: options,
            progressBlock: { receivedSize, totalSize in
                guard resource.downloadURL == self.webURL else {
                    return
                }
                if let progressBlock = progressBlock {
                    progressBlock(receivedSize, totalSize)
                }
            },
            completionHandler: {[weak base] image, error, cacheType, imageURL in
                DispatchQueue.main.safeAsync {
                    maybeIndicator?.stopAnimatingView()
                    guard let strongBase = base, imageURL == self.webURL else {
                        completionHandler?(image, error, cacheType, imageURL)
                        return
                    }
                    
                    self.setImageTask(nil)
                    guard let image = image else {
                        completionHandler?(nil, error, cacheType, imageURL)
                        return
                    }
                    
                    guard let transitionItem = options.lastMatchIgnoringAssociatedValue(.transition(.none)),
                        case .transition(let transition) = transitionItem, ( options.forceTransition || cacheType == .none) else
                    {
                        strongBase.image = image
                        completionHandler?(image, error, cacheType, imageURL)
                        return
                    }
                    
                    #if !os(macOS)
                        UIView.transition(with: strongBase, duration: 0.0, options: [],
                                          animations: { maybeIndicator?.stopAnimatingView() },
                                          completion: { _ in
                                            UIView.transition(with: strongBase, duration: transition.duration,
                                                              options: [transition.animationOptions, .allowUserInteraction],
                                                              animations: {
                                                                // Set image property in the animation.
                                                                transition.animations?(strongBase, image)
                                                              },
                                                              completion: { finished in
                                                                transition.completion?(finished)
                                                                completionHandler?(image, error, cacheType, imageURL)
                                                              })
                                          })
                    #endif
                }
            })
        
        setImageTask(task)
        
        return task
    }
    
    /**
     Cancel the image download task bounded to the image view if it is running.
     Nothing will happen if the downloading has already finished.
     */
    public func cancelDownloadTask() {
        imageTask?.cancel()
    }
}

// MARK: - Associated Object
private var lastURLKey: Void?
private var indicatorKey: Void?
private var indicatorTypeKey: Void?
private var imageTaskKey: Void?

extension Imagery where Base: ImageViewType {
    /// Get the image URL binded to this image view.
    public var webURL: URL? {
        return objc_getAssociatedObject(base, &lastURLKey) as? URL
    }
    
    fileprivate func setWebURL(_ url: URL?) {
        objc_setAssociatedObject(base, &lastURLKey, url, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /// Holds which indicator type is going to be used.
    /// Default is .none, means no indicator will be shown.
    public var indicatorType: ImageryIndicatorType {
        get {
            let indicator = (objc_getAssociatedObject(base, &indicatorTypeKey) as? Proxy<ImageryIndicatorType?>)?.value
            return indicator ?? .none
        }
        
        set {
            switch newValue {
            case .none:
                indicator = nil
            case .activity:
                indicator = ImageryActivityIndicator()
            case .image(let data):
                indicator = ImageryImageIndicator(imageData: data)
            case .custom(let anIndicator):
                indicator = anIndicator
            }
            
            objc_setAssociatedObject(base, &indicatorTypeKey, Proxy(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// Holds any type that conforms to the protocol `ImageryIndicator`.
    /// The protocol `ImageryIndicator` has a `view` property that will be shown when loading an image.
    /// It will be `nil` if `indicatorType` is `.none`.
    public fileprivate(set) var indicator: ImageryIndicator? {
        get {
            return (objc_getAssociatedObject(base, &indicatorKey) as? Proxy<ImageryIndicator?>)?.value
        }
        
        set {
            // Remove previous
            if let previousIndicator = indicator {
                previousIndicator.view.removeFromSuperview()
            }
            
            // Add new
            if var newIndicator = newValue {
                // Set default indicator frame if the view's frame not set.
                if newIndicator.view.frame != .zero {
                    newIndicator.view.frame = base.frame
                }
                newIndicator.viewCenter = CGPoint(x: base.bounds.midX, y: base.bounds.midY)
                newIndicator.view.isHidden = true
                base.addSubview(newIndicator.view)
            }
            
            // Save in associated object
            objc_setAssociatedObject(base, &indicatorKey, Proxy(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var imageTask: ImageryRetrieveImageTask? {
        return objc_getAssociatedObject(base, &imageTaskKey) as? ImageryRetrieveImageTask
    }
    
    fileprivate func setImageTask(_ task: ImageryRetrieveImageTask?) {
        objc_setAssociatedObject(base, &imageTaskKey, task, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

extension ImageViewType {
    func shouldPreloadAllAnimation() -> Bool { return true }
}
