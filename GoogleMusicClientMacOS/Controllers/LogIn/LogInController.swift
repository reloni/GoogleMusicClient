//
//  LogInController.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 13/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa
import RxGoogleMusic

final class LogInController: BaseViewController<LogInCoordinator>, ApplicationController {    
    @IBAction func logIn(_ sender: Any) {
        let authController = GMusicAuthenticationController { [weak self] result in
            switch result {
            case .authenticated(let token): self?.coordinator.showMainController(accessToken: token)
            case .error(let e):
                print("error: \(e)")
            case .userAborted:
                print("userAborted")
            }
        }
        
        presentAsModalWindow(authController)
    }
    
    deinit {
        print("LogInController deinit")
    }
}
