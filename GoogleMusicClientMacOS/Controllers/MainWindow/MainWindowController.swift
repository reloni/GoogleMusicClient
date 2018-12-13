//
//  MainWindowController.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 13/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa

final class MainWindowController: NSWindowController, ApplicationController {
    lazy var startupCoordinator: StartupCoordinator = { StartupCoordinator(windowController: self) }()
    override func windowDidLoad() {
        super.windowDidLoad()

        startupCoordinator.show()
    }
}
