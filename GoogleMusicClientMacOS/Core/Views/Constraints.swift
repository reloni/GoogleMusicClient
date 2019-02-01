//
//  Constraints.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 18/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa

class Layout {
    class Anchor {
        enum AnchorType {
            case xAxis(NSLayoutXAxisAnchor)
            case yAxis(NSLayoutYAxisAnchor)
            case dimension(NSLayoutDimension)
        }
        let owner: NSView
        let target: AnchorType
        init(target: AnchorType, owner: NSView) {
            self.target = target
            self.owner = owner
        }
    }
    let target: NSView
    init(target: NSView) {
        self.target = target
    }
}

extension NSView {
    var lt: Layout { return Layout(target: self) }
}

extension Layout {
    var leading: Layout.Anchor {
        return Layout.Anchor(target: Layout.Anchor.AnchorType.xAxis(target.leadingAnchor), owner: target)
    }
    
    var trailing: Layout.Anchor {
        return Layout.Anchor(target: Layout.Anchor.AnchorType.xAxis(target.trailingAnchor), owner: target)
    }
    
    var top: Layout.Anchor {
        return Layout.Anchor(target: Layout.Anchor.AnchorType.yAxis(target.topAnchor), owner: target)
    }
    
    var bottom: Layout.Anchor {
        return Layout.Anchor(target: Layout.Anchor.AnchorType.yAxis(target.bottomAnchor), owner: target)
    }
    
    var height: Layout.Anchor {
        return Layout.Anchor(target: Layout.Anchor.AnchorType.dimension(target.heightAnchor), owner: target)
    }
    
    var width: Layout.Anchor {
        return Layout.Anchor(target: Layout.Anchor.AnchorType.dimension(target.widthAnchor), owner: target)
    }
    
    var centerX: Layout.Anchor {
        return Layout.Anchor(target: Layout.Anchor.AnchorType.xAxis(target.centerXAnchor), owner: target)
    }
    
    var centerY: Layout.Anchor {
        return Layout.Anchor(target: Layout.Anchor.AnchorType.yAxis(target.centerYAnchor), owner: target)
    }
    
    @discardableResult func edges(to other: NSView, constant: CGFloat = 0.0) -> [NSLayoutConstraint] {
        return [top(to: other.lt.top, constant: constant),
                leading(to: other.lt.leading, constant: constant),
                trailing(to: other.lt.trailing, constant: constant),
                bottom(to: other.lt.bottom, constant: constant)
        ]
    }
    
    @discardableResult func leading(to other: Layout.Anchor, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        return makeConstraint(leading, other, constant: constant)
    }
    
    @discardableResult func trailing(to other: Layout.Anchor, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        return makeConstraint(trailing, other, constant: constant)
    }
    
    @discardableResult func top(to other: Layout.Anchor, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        return makeConstraint(top, other, constant: constant)
    }
    
    @discardableResult func bottom(to other: Layout.Anchor, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        return makeConstraint(bottom, other, constant: constant)
    }
    
    @discardableResult func height(to other: Layout.Anchor, constant: CGFloat = 0.0, multiplier: CGFloat = 1.0) -> NSLayoutConstraint {
        return makeConstraint(height, other, constant: constant, multiplier: multiplier)
    }
    
    @discardableResult func width(to other: Layout.Anchor, constant: CGFloat = 0.0, multiplier: CGFloat = 1.0) -> NSLayoutConstraint {
        return makeConstraint(width, other, constant: constant, multiplier: multiplier)
    }
    
    @discardableResult func centerX(to other: Layout.Anchor, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        return makeConstraint(centerX, other, constant: constant)
    }
    
    @discardableResult func centerY(to other: Layout.Anchor, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        return makeConstraint(centerY, other, constant: constant)
    }
    
    private func makeConstraint(_ lhs: Layout.Anchor, _ rhs: Layout.Anchor, constant: CGFloat, multiplier: CGFloat = 1.0) -> NSLayoutConstraint {
        lhs.owner.translatesAutoresizingMaskIntoConstraints = false
        rhs.owner.translatesAutoresizingMaskIntoConstraints = false
        let constraint: NSLayoutConstraint = {
            switch (lhs.target, rhs.target) {
            case let (.xAxis(l), .xAxis(r)): return l.constraint(equalTo: r, constant: constant)
            case let (.yAxis(l), .yAxis(r)): return l.constraint(equalTo: r, constant: constant)
            case let (.dimension(l), .dimension(r)): return l.constraint(equalTo: r, multiplier: multiplier, constant: constant)
            default: fatalError()
            }
        }()
        constraint.isActive = true
        return constraint
    }
}


