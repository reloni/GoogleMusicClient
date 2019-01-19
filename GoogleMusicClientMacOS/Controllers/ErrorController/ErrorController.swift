//
//  ErrorController.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 19/01/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Cocoa

final class ErrorController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.systemRed.cgColor
    }
}
