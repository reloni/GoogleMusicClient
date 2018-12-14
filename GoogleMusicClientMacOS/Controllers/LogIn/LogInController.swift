//
//  LogInController.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 13/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa
import RxDataFlow
import RxGoogleMusic

final class LogInController: NSViewController {    
    @IBAction func logIn(_ sender: Any) {
        let authController = GMusicAuthenticationController { result in
            switch result {
            case .authenticated(let token):
                Global.current.dataFlowController.dispatch(RxCompositeAction(SystemAction.saveKeychainToken(token),
                                                                             UIAction.showMain))
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
