//
//  SystemReducer.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 14/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import RxSwift
import RxDataFlow
import RxGoogleMusic

func systemReducer(_ action: RxActionType, currentState: AppState) -> Observable<RxStateMutator<AppState>> {
    switch action {
    case SystemAction.clearKeychainToken:
        clearKeychainToken(keychain: currentState.keychain)
        break
    case SystemAction.saveKeychainToken(let token):
        saveInKeychain(token: token, keychain: currentState.keychain)
        break
    default:
        break
    }
    
    return .just( { $0 } )
}

private func saveInKeychain(token: GMusicToken, keychain: KeychainType) {
    keychain.accessToken = token.accessToken
    keychain.expiresAt = token.expiresAt
    keychain.refreshToken = token.refreshToken
}

private func clearKeychainToken(keychain: KeychainType) {
    keychain.accessToken = nil
    keychain.expiresAt = nil
    keychain.refreshToken = nil
}
