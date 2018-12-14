//
//  ApplicationGlobal.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 13/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import RxGoogleMusic
import RxSwift
import RxDataFlow

struct Global {
    static var current: Global = Global()    
    var dataFlowController = RxDataFlowController(reducer: rootReducer,
                                                  initialState: AppState(coordinator: StartupCoordinator(), keychain: Keychain()))
}

extension Global {
    var authenticated: Bool {
        return dataFlowController.currentState.state.keychain.accessToken != nil
    }
    
    var gMusicToken: GMusicToken? {
        let keychain = dataFlowController.currentState.state.keychain
        guard let token = keychain.accessToken else { return nil }
        return GMusicToken(accessToken: token,
                           expiresIn: keychain.expiresIn,
                           refreshToken: keychain.refreshToken)
    }
}
