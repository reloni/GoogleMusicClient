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
import Foundation

func systemReducer(_ action: RxActionType, currentState: AppState) -> RxReduceResult<AppState> {
    switch action {
    case SystemAction.creanup:
        clearKeychainToken(keychain: currentState.keychain)
        return RxReduceResult.single { $0.cleaned() }
    case SystemAction.saveKeychainToken(let token):
        saveInKeychain(token: token, keychain: currentState.keychain)
    case SystemAction.initializeMusicClient:
        guard let token = currentState.gMusicToken else { return RxReduceResult.empty }
        return RxReduceResult.single({ $0.mutate(\.client, GMusicClient(token: token, session: URLSession(configuration: .default), locale: Locale.current)) })
    case SystemAction.initializePlayer:
        guard let client = currentState.client else { return RxReduceResult.empty }
        let player = Player<GMusicTrack>(loadRequest: client.downloadTrack)
        return RxReduceResult.single({ $0.mutate(\.player, player) })
    default:
        break
    }
    
    return RxReduceResult.empty
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
