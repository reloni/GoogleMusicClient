//
//  HighlightOnHoverTableRowView.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 27/01/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Cocoa

protocol HoverView {
    var isHovered: Bool { get set }
    func drawHoverBackground(_ rect: NSRect)
}

extension HoverView {
    func drawHoverBackground(_ rect: NSRect) {
        guard isHovered else { return }
        
        let color = NSColor.selectedContentBackgroundColor.withAlphaComponent(0.25)
        
        color.setStroke()
        color.setFill()
        
        let selectionPath = NSBezierPath.init(roundedRect: rect, xRadius: 0, yRadius: 0)
        selectionPath.fill()
        selectionPath.stroke()
    }
}

final class HighlightOnHoverView: NSView, HoverView {
    var isHovered = false
    
    override var trackingAreaOptions: NSTrackingArea.Options {
        get { return [NSTrackingArea.Options.activeInActiveApp, NSTrackingArea.Options.mouseEnteredAndExited] }
        set { }
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
    
    override func draw(_ dirtyRect: NSRect) {
        drawHoverBackground(bounds)
    }
}


final class HighlightOnHoverTableRowView: NSTableRowView, HoverView {
    var isHovered = false
    
    override var trackingAreaOptions: NSTrackingArea.Options {
        get { return [NSTrackingArea.Options.activeInActiveApp, NSTrackingArea.Options.mouseEnteredAndExited] }
        set { }
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
        drawHoverBackground(bounds)
    }
}
