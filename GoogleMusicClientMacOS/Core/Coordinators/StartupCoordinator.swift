//
//  StartupCoordinator.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 13/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa

final class StartupCoordinator {
    private unowned let windowController: NSWindowController
    
    init(windowController: NSWindowController) {
        self.windowController = windowController
    }
    
    func show() {
        if Global.current.hasGMusicToken {
            let controller = MainController.instantiate()
            controller.coordinator = MainCoordinator(windowController: windowController)
            windowController.replaceContentController(controller)
        } else {
            let controller = LogInController.instantiate()
            controller.coordinator = LogInCoordinator(windowController: windowController)
            windowController.replaceContentController(controller)
        }
    }
}
