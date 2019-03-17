//
//  LayoutPriority.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 17/03/2019.
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
