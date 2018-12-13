//
//  ApplicationController.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 13/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa

extension NSWindowController {
    func replaceContentController(_ newController: NSViewController) {
        NSAnimationContext.runAnimationGroup({ _ in
            contentViewController?.view.animator().alphaValue = 0
        }, completionHandler: {
            newController.view.alphaValue = 0
            self.contentViewController = newController
            newController.view.animator().alphaValue = 1.0
        })
        window?.title = newController.title ?? ""
    }
}

class BaseViewController<Coordinator>: NSViewController {
    var coordinator: Coordinator!
}

protocol ApplicationController {
    static var controllerName: String { get }
    static var storyboard: NSStoryboard { get }
    static func instantiate() -> Self
}

extension ApplicationController {
    static var controllerName: String {
        return String(describing: self)
    }
    
    static var storyboard: NSStoryboard {
        return NSStoryboard(name: controllerName, bundle: nil)
    }
    
    static func instantiate() -> Self {
        return storyboard.instantiateController(withIdentifier: controllerName) as! Self
    }
}
