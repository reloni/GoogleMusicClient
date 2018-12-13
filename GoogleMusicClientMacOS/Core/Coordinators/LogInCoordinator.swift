//
//  LogInCoordinator.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 13/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa
import RxGoogleMusic

final class LogInCoordinator {
    private unowned let windowController: NSWindowController
    
    init(windowController: NSWindowController) {
        self.windowController = windowController
    }
    
    func showMainController(accessToken token: GMusicToken) {
        let controller = MainController.instantiate()
        controller.coordinator = MainCoordinator(windowController: windowController)
        windowController.replaceContentController(controller)
    }
}
