//
//  VerticallyCenteredTextField.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 01/02/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Cocoa

final class VerticallyCenteredTextField: NSView {
    let textField = NSTextField()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        addSubview(textField)
        textField.lt.leading(to: lt.leading)
        textField.lt.trailing(to: lt.trailing)
        textField.lt.centerY(to: lt.centerY)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
