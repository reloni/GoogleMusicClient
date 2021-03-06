//
//  ApplicationTableView.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 17/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa

final class ApplicationTableView: NSTableView {
    var didClickRow: ((Int) -> Void)?
    
    override func drawGrid(inClipRect clipRect: NSRect) { }
    
    override func drawBackground(inClipRect clipRect: NSRect) { }
    
    override func reloadData() {
        if numberOfRows > 0 {
            removeRows(at: IndexSet(0..<numberOfRows), withAnimation: NSTableView.AnimationOptions.effectFade)
        }
        
        guard let rows = dataSource?.numberOfRows?(in: self), rows > 0 else { return }
        
        insertRows(at: IndexSet(0..<rows), withAnimation: NSTableView.AnimationOptions.slideDown)
    }
    
    override func mouseDown(with event: NSEvent) {
        let clickedRow = row(at: convert(event.locationInWindow, from: nil))
        
        super.mouseDown(with: event)
        
        guard clickedRow != -1 else { return }
        
        didClickRow?(clickedRow)
    }
}

