//
//  HighlightOnHoverTableRowView.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 27/01/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Cocoa

final class HighlightOnHoverTableRowView: NSTableRowView {
    var isHovered = false
    
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
        isHovered = false
        setNeedsDisplay(bounds)
    }
    
    override func mouseEntered(with event: NSEvent) {
        isHovered = true
        setNeedsDisplay(bounds)
    }
    
    override func drawBackground(in dirtyRect: NSRect) {
        guard isHovered else { return }
        
        let color = NSColor.selectedContentBackgroundColor.withAlphaComponent(0.25)
        
        color.setStroke()
        color.setFill()
        
        let selectionPath = NSBezierPath.init(roundedRect: bounds, xRadius: 0, yRadius: 0)
        selectionPath.fill()
        selectionPath.stroke()
    }
}
