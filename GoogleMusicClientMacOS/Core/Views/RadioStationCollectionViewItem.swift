//
//  RadioStationCollectionViewItem.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 09/03/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Cocoa

extension NSView {
    enum LayoutPriority {
        case hugging(Float, NSLayoutConstraint.Orientation)
        case compression(Float, NSLayoutConstraint.Orientation)
        
        var value: NSLayoutConstraint.Priority {
            switch self {
            case .hugging(let v), .compression(let v): return NSLayoutConstraint.Priority(v.0)
            }
        }
        
        var orientation: NSLayoutConstraint.Orientation {
            switch self {
            case .hugging(let v): return v.1
            case .compression(let v): return v.1
            }
        }
        
        func set(to view: NSView) {
            switch self {
            case .compression: view.setContentCompressionResistancePriority(value, for: orientation)
            case .hugging: view.setContentHuggingPriority(value, for: orientation)
            }
        }
    }
    
    func setContentPriority(_ priority: NSView.LayoutPriority) {
        priority.set(to: self)
    }
}

extension NSImage {
    func blurred(radius: CGFloat) -> NSImage {
//        let ciContext = CIContext(options: nil)
//
//        guard let tiff = tiffRepresentation else { return self }
//        guard let cgImage = CIImage(data: tiff) else { return self }
////        let inputImage = CIImage(cgImage: cgImage)
//        guard let ciFilter = CIFilter(name: "CIGaussianBlur") else { return self }
//        ciFilter.setValue(cgImage, forKey: kCIInputImageKey)
//        ciFilter.setValue(radius, forKey: "inputRadius")
//        guard let resultImage = ciFilter.value(forKey: kCIOutputImageKey) as? CIImage else { return self }
//        guard let cgImage2 = ciContext.createCGImage(resultImage, from: cgImage.extent) else { return self }
//        return NSImage(cgImage: cgImage2)
        
        var originalImage = self
        var inputImage = CIImage(data: originalImage.tiffRepresentation!)
        var filter = CIFilter(name: "CIGaussianBlur")
        filter!.setDefaults()
        filter!.setValue(inputImage, forKey: kCIInputImageKey)
        filter!.setValue(radius, forKey: "inputRadius")
        var outputImage = filter!.value(forKey: kCIOutputImageKey) as! CIImage
        var outputImageRect = NSRectFromCGRect(outputImage.extent)
        var blurredImage = NSImage(size: outputImageRect.size)
        blurredImage.lockFocus()
        outputImage.draw(at: NSZeroPoint, from: outputImageRect, operation: .copy, fraction: 1.0)
        blurredImage.unlockFocus()

        return blurredImage
        
    }
}

final class RadioStationCollectionViewItem: NSCollectionViewItem {
    let image = NSImageView()
        |> mutate(^\NSImageView.imageScaling, NSImageScaling.scaleProportionallyUpOrDown)
    let backgroundImage = NSImageView()
        |> mutate(^\NSImageView.imageScaling, NSImageScaling.scaleNone)
    let titleLabel = baseLabel()
        |> mutate(^\NSTextField.font, ApplicationFont.semibold.value)
        |> mutate(^\NSTextField.alignment, NSTextAlignment.center)
        |> mutate { $0.setContentPriority(.hugging(1000, .vertical)) }
        |> mutate { $0.setContentPriority(.compression(1000, .vertical)) }
    
    override func loadView() {
        view = NSView()
        view.addSubview(backgroundImage)
        view.addSubview(image)
        
        
        
//        backgroundImage.contentFilters =
        
        view.addSubview(titleLabel)
        
//        titleLabel.setContentPriority(.hugging(1000, .vertical))
//        titleLabel.setContentPriority(.compression(1000, .vertical))
        
        createConstraints()
        
//        let base = baseLabel()
//        let a = base
//            |> mutate(^\NSTextField.font, ApplicationFont.semibold.value)
//            |> mutate { $0.setContentPriority(.hugging(1000, .vertical)) }
        
        
        image.image = NSImage(imageLiteralResourceName: "Album")
    }
    
    func createConstraints() {
        backgroundImage.lt.top.equal(to: view.lt.top, constant: 5)
        backgroundImage.lt.leading.equal(to: view.lt.leading, constant: 5)
        backgroundImage.lt.trailing.equal(to: view.lt.trailing, constant: 5)
        
        image.lt.centerX.equal(to: backgroundImage.lt.centerX, constant: 0)
        image.lt.centerY.equal(to: backgroundImage.lt.centerY, constant: 0)
        
//        image.lt.width.equal(to: 40)
//        image.lt.height.equal(to: 40)
//        image.topAnchor.constraint(lessThanOrEqualTo: backgroundImage.topAnchor)
        image.heightAnchor.constraint(equalTo: image.widthAnchor)
        image.lt.leading.equal(to: backgroundImage.lt.leading)
        image.lt.trailing.equal(to: backgroundImage.lt.trailing)
        
//        image.lt.top.equal(to: view.lt.top, constant: 10)
//        image.lt.leading.equal(to: view.lt.leading, constant: 10)
//        image.lt.trailing.equal(to: view.lt.trailing, constant: 10)
        
        titleLabel.lt.top.equal(to: backgroundImage.lt.bottom, constant: 5)
//        titleLabel.lt.top.equal(to: view.lt.top, constant: 5)
        titleLabel.lt.leading.equal(to: backgroundImage.lt.leading)
        titleLabel.lt.trailing.equal(to: backgroundImage.lt.trailing)
//        titleLabel.lt.leading.equal(to: view.lt.leading)
//        titleLabel.lt.trailing.equal(to: view.lt.trailing)
        titleLabel.lt.bottom.equal(to: view.lt.bottom, constant: -5)
    }
}
