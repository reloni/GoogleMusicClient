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

func systemReducer(_ action: RxActionType, currentState: AppState) -> RxReduceResult<AppState> {
    switch action {
    case SystemAction.clearKeychainToken:
        clearKeychainToken(keychain: currentState.keychain)
        break
    case SystemAction.saveKeychainToken(let token):
        saveInKeychain(token: token, keychain: currentState.keychain)
        break
    case SystemAction.initializeMusicClient:
        guard let token = currentState.gMusicToken else { return RxReduceResult.empty }
        return RxReduceResult.single({ $0.mutate(\.client, GMusicClient(token: token)) })
    case SystemAction.initializePlayer:
        guard let client = currentState.client else { return RxReduceResult.empty }
        let player = Player(rootPath: Global.musicDirectory, loadRequest: client.downloadTrack, items: [])
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
