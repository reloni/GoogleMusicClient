//
//  MainCoordinator.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 13/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa

final class MainCoordinator {
    private unowned let windowController: NSWindowController
    
    init(windowController: NSWindowController) {
        self.windowController = windowController
    }
    
    func showLogIn() {
        let controller = LogInController.instantiate()
        controller.coordinator = LogInCoordinator(windowController: windowController)
        windowController.replaceContentController(controller)
    }
}
