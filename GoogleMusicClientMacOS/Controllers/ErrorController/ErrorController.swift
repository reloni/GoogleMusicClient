//
//  ErrorController.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 19/01/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Cocoa

final class ErrorController: NSViewController {
    @IBOutlet weak var textLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.systemRed.cgColor
    }
    
    @IBAction func cancelButtonClick(_ sender: Any) {
        Current.dispatch(UIAction.hideErrorController)
    }
    
}
