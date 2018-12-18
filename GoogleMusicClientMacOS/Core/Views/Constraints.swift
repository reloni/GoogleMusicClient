//
//  Constraints.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 18/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa

class Layout {
    class Anchor<AnchorType: AnyObject> {
        let owner: NSView
        let target: NSLayoutAnchor<AnchorType>
        init(target: NSLayoutAnchor<AnchorType>, owner: NSView) {
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
    var leading: Layout.Anchor<NSLayoutXAxisAnchor> {
        return Layout.Anchor(target: target.leadingAnchor, owner: target)
    }
    
    var trailing: Layout.Anchor<NSLayoutXAxisAnchor> {
        return Layout.Anchor(target: target.trailingAnchor, owner: target)
    }
    
    var top: Layout.Anchor<NSLayoutYAxisAnchor> {
        return Layout.Anchor(target: target.topAnchor, owner: target)
    }
    
    var bottom: Layout.Anchor<NSLayoutYAxisAnchor> {
        return Layout.Anchor(target: target.bottomAnchor, owner: target)
    }
    
    @discardableResult func edges(to other: NSView, constant: CGFloat = 0.0) -> [NSLayoutConstraint] {
        return [top(to: other, constant: constant),
                leading(to: other, constant: constant),
                trailing(to: other, constant: constant),
                bottom(to: other, constant: constant)
        ]
    }
    
    @discardableResult func leading(to other: NSView, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        return makeConstraint(leading, other.lt.leading, constant: constant)
    }
    
    @discardableResult func trailing(to other: NSView, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        return makeConstraint(trailing, other.lt.trailing, constant: constant)
    }
    
    @discardableResult func top(to other: NSView, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        return makeConstraint(top, other.lt.top, constant: constant)
    }
    
    @discardableResult func bottom(to other: NSView, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        return makeConstraint(bottom, other.lt.bottom, constant: constant)
    }
    
    private func makeConstraint<AnchorType>(_ lhs: Layout.Anchor<AnchorType>, _ rhs: Layout.Anchor<AnchorType>, constant: CGFloat) -> NSLayoutConstraint {
        lhs.owner.translatesAutoresizingMaskIntoConstraints = false
        rhs.owner.translatesAutoresizingMaskIntoConstraints = false
        let constraint = lhs.target.constraint(equalTo: rhs.target, constant: 0)
        constraint.isActive = true
        return constraint
    }
}
