//
//  MainWindowController.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 13/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa
import RxDataFlow

final class MainWindowController: NSWindowController, ApplicationController {
    override func windowDidLoad() {
        super.windowDidLoad()
        
        Global.current.dataFlowController.dispatch(SystemAction.initializeMusicClient)
        Global.current.dataFlowController.dispatch(UIAction.startup(self))
    }
}
