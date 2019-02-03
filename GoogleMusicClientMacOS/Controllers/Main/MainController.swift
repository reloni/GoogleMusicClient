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
    
    func showQueuePopover(for view: NSView) {
        let popover = NSPopover()
        popover.contentViewController = QueueController2()
        popover.behavior = .semitransient
        popover.animates = true
        
        popover.contentSize = NSSize(width: mainContainerView.frame.width * 0.9, height: mainContainerView.frame.height - 15)
        popover.show(relativeTo: .zero, of: view, preferredEdge: NSRectEdge.minY)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func toggleErrorController(isVisible: Bool) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.allowsImplicitAnimation = true
            context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            self.errorContainerTopToBottomContainerTopConstraint.isActive = !isVisible
            self.errorContainerBottomToBottomContainerTopConstraint.isActive = isVisible
            self.view.layoutSubtreeIfNeeded()
        }
    }
    
    deinit {
        print("MainController deinit")
    }
}
