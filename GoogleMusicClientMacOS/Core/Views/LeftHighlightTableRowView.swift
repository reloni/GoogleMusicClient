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


final class HighlightOnHoverTableRowView: NSTableRowView {
    var isHighlighted = false
    
    override var trackingAreaOptions: NSTrackingArea.Options {
        return [NSTrackingArea.Options.activeInActiveApp, NSTrackingArea.Options.mouseEnteredAndExited]
    }
    
    init() {
        super.init(frame: .zero)
        setupTrackingArea()
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mouseExited(with event: NSEvent) {
        isHighlighted = false
        setNeedsDisplay(bounds)
    }
    
    override func mouseEntered(with event: NSEvent) {
        isHighlighted = true
        setNeedsDisplay(bounds)
    }
    
    override func drawBackground(in dirtyRect: NSRect) {
        guard isHighlighted else { return }
        
        print(bounds)
        
        let color = NSColor.selectedContentBackgroundColor.withAlphaComponent(0.25)
        
        color.setStroke()
        color.setFill()
        
        let selectionPath = NSBezierPath.init(roundedRect: bounds, xRadius: 0, yRadius: 0)
        selectionPath.fill()
        selectionPath.stroke()
    }
}
