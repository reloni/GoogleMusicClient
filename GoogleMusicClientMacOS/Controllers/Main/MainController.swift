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
    
    func showQueuePopover(for view: NSView) {
        let popover = NSPopover()
        popover.contentViewController = QueueController.instantiate()
        popover.behavior = .semitransient
        popover.animates = true
        
        popover.contentSize = NSSize(width: mainContainerView.frame.width * 0.9, height: mainContainerView.frame.height - 15)
        popover.show(relativeTo: .zero, of: view, preferredEdge: NSRectEdge.minY)
    }
    
    deinit {
        print("MainController deinit")
    }
}
