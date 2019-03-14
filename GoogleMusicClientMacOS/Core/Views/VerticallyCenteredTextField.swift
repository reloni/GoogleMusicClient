//
//  VerticallyCenteredTextField.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 01/02/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Cocoa
import GoogleMusicClientCore

final class VerticallyCenteredTextField: NSView {
    let textField = baseLabel()
        |> mutate(^\NSTextField.font, ApplicationFont.semibold.value)
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        addSubview(textField)
        textField.lt.leading.equal(to: lt.leading)
        textField.lt.trailing.equal(to: lt.trailing)
        textField.lt.centerY.equal(to: lt.centerY)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
