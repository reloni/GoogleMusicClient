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
                Current.dispatch(CompositeActions.logIn(token: token))
            case .error(let e):
                let alert = AlertConfiguration.init(messageText: "Authentication error",
                                                    informativeText: e.localizedDescription,
                                                    alertStyle: .critical,
                                                    buttonTitles: ["OK"],
                                                    completion: { _ in })
                Current.dispatch(UIAction.showAlert(alert))
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
