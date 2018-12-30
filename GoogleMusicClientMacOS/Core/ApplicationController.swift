//
//  ApplicationController.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 13/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa

protocol ApplicationWindowController: class {
    func replaceContentController(_ newController: ApplicationController)
}

extension NSWindowController: ApplicationWindowController {
    func replaceContentController(_ newController: ApplicationController) {
        guard let controller = newController as? NSViewController else { return }
        NSAnimationContext.runAnimationGroup({ _ in
            contentViewController?.view.animator().alphaValue = 0
        }, completionHandler: {
            let frame = self.window!.frame
            
            controller.view.alphaValue = 0
            self.contentViewController = controller
            controller.view.animator().alphaValue = 1.0
            
            self.window?.setFrame(frame, display: true)
        })
        window?.title = controller.title ?? ""
    }
}

protocol ApplicationController {
    static var controllerName: String { get }
    static var storyboard: NSStoryboard { get }
    static func instantiate() -> Self
}

extension NSViewController: ApplicationController { }

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
