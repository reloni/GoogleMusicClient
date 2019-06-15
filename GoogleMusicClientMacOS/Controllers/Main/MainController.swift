//
//  MainController.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 13/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa
import RxDataFlow
import RxSwift
import RxCocoa
import RxGoogleMusic

final class MainController: NSViewController {
    @IBOutlet weak var leftContainerView: NSView!
    @IBOutlet weak var mainContainerView: NSView!
    @IBOutlet weak var bottomContainerView: NSView!
    @IBOutlet weak var topContainerView: NSView!
    @IBOutlet weak var errorContainerView: NSView!
    
    @IBOutlet var errorContainerTopToBottomContainerTopConstraint: NSLayoutConstraint!
    @IBOutlet var errorContainerBottomToBottomContainerTopConstraint: NSLayoutConstraint!
    
    func showPopover(content: NSViewController, relativeView: NSView, contentSize: NSSize) {
        let popover = NSPopover()
        popover.contentViewController = content
        popover.behavior = .semitransient
        popover.animates = true
        popover.contentSize = contentSize

        popover.show(relativeTo: .zero, of: relativeView, preferredEdge: NSRectEdge.maxY)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func toggleErrorController(isVisible: Bool) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            context.allowsImplicitAnimation = true
            context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            self.errorContainerTopToBottomContainerTopConstraint.isActive = !isVisible
            self.errorContainerBottomToBottomContainerTopConstraint.isActive = isVisible
            if isVisible {
                self.errorContainerView.isHidden = false
            }
            self.view.layoutSubtreeIfNeeded()
        }, completionHandler: { self.errorContainerView.isHidden = !isVisible })
    }
    
    deinit {
        print("MainController deinit")
    }
}
