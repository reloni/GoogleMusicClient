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

extension Layout.Anchor {
    @discardableResult func equal(to constant: CGFloat) -> NSLayoutConstraint {
        return makeConstraint(self, equalToConstant: constant)
    }
    
    @discardableResult func equal(to other: Layout.Anchor, constant: CGFloat = 0.0, multiplier: CGFloat = 1.0) -> NSLayoutConstraint {
        return makeConstraint(self, other, constant: constant, multiplier: multiplier)
    }
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
        return [target.lt.top.equal(to: other.lt.top, constant: constant),
                target.lt.leading.equal(to: other.lt.leading, constant: constant),
                target.lt.trailing.equal(to: other.lt.trailing, constant: constant),
                target.lt.bottom.equal(to: other.lt.bottom, constant: constant)
        ]
    }
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

private func makeConstraint(_ anchor: Layout.Anchor, equalToConstant constant: CGFloat) -> NSLayoutConstraint {
    anchor.owner.translatesAutoresizingMaskIntoConstraints = false
    let constraint: NSLayoutConstraint = {
        switch anchor.target {
        case .dimension(let t): return t.constraint(equalToConstant: constant)
        default: fatalError()
        }
    }()
    constraint.isActive = true
    return constraint
}
