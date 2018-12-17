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

private func initialState() -> AppState {
    return AppState(coordinator: StartupCoordinator(), keychain: Keychain())
}

struct Global {
    static var current: Global = Global()    
    var dataFlowController = RxDataFlowController(reducer: rootReducer, initialState: initialState())
}

extension Global {
    var authenticated: Bool { return dataFlowController.currentState.state.keychain.accessToken != nil }
    
    var gMusicToken: GMusicToken? {
        let keychain = dataFlowController.currentState.state.keychain
        guard let token = keychain.accessToken else { return nil }
        return GMusicToken(accessToken: token,
                           expiresAt: keychain.expiresAt,
                           refreshToken: keychain.refreshToken)
    }
}
