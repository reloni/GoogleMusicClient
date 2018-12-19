//
//  LeftHighlightTableRowView.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 18/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa

final class LeftHighlightTableRowView: NSTableRowView {
    override func drawSelection(in dirtyRect: NSRect) {
        if self.selectionHighlightStyle != .none {
            let selectionRect = NSRect(x: dirtyRect.origin.x,
                                       y: dirtyRect.origin.y,
                                       width: 6,
                                       height: dirtyRect.height)
            
            let color = NSColor.selectedContentBackgroundColor.withAlphaComponent(0.5)
            
            color.setStroke()
            color.setFill()
            
            let selectionPath = NSBezierPath.init(roundedRect: selectionRect, xRadius: 0, yRadius: 0)
            selectionPath.fill()
            selectionPath.stroke()
        }
    }
}
