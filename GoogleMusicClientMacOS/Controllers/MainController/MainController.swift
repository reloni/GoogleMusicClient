//
//  MainController.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 13/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa

final class MainController: BaseViewController<MainCoordinator>, ApplicationController {   
    @IBAction func logOff(_ sender: Any) {
        coordinator.showLogIn()
    }
    
    deinit {
        print("MainController deinit")
    }
}
