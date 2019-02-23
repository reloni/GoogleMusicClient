//
//  ViewWithBottomBorder.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 23/02/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Cocoa

protocol ViewWithBottomBorder {
    func createBottomBorder() -> NSBox
    func addBottomBorder(to view: NSView)
}

extension ViewWithBottomBorder {
    func createBottomBorder() -> NSBox {
        return NSBox().configure {
            $0.boxType = NSBox.BoxType.separator
            $0.borderType = NSBorderType.lineBorder
        }
    }
    
    func addBottomBorder(to view: NSView) {
        let border = createBottomBorder()
        view.addSubview(border)
        border.lt.height.equal(to: 1)
        border.lt.leading.equal(to: view.lt.leading)
        border.lt.trailing.equal(to: view.lt.trailing)
        border.lt.bottom.equal(to: view.lt.bottom)
    }
}
