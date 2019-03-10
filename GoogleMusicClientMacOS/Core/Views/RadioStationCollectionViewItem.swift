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

final class RadioStationCollectionViewItem: NSCollectionViewItem {
    let image = NSImageView()
    let titleLabel = NSTextField()
        |> baseLabel()
        |> font(.semibold)
        |> alignment(.center)
    
    override func loadView() {
        view = NSView()
        view.addSubview(image)
        view.addSubview(titleLabel)
        
        image.imageScaling = .scaleProportionallyUpOrDown
        titleLabel.setContentPriority(.hugging(1000, .vertical))
        titleLabel.setContentPriority(.compression(1000, .vertical))
        
        createConstraints()
        
        
        image.image = NSImage(imageLiteralResourceName: "Album")
    }
    
    func createConstraints() {
        image.lt.top.equal(to: view.lt.top, constant: 5)
        image.lt.leading.equal(to: view.lt.leading, constant: 5)
        image.lt.trailing.equal(to: view.lt.trailing, constant: 5)
        
        titleLabel.lt.top.equal(to: image.lt.bottom, constant: 5)
//        titleLabel.lt.top.equal(to: view.lt.top, constant: 5)
        titleLabel.lt.leading.equal(to: image.lt.leading)
        titleLabel.lt.trailing.equal(to: image.lt.trailing)
//        titleLabel.lt.leading.equal(to: view.lt.leading)
//        titleLabel.lt.trailing.equal(to: view.lt.trailing)
        titleLabel.lt.bottom.equal(to: view.lt.bottom, constant: -5)
    }
}
