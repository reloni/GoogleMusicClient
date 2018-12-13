//
//  ApplicationGlobal.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 13/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import RxGoogleMusic

struct Global {
    static var current: Global = Global()
    var keychain: KeychainType = Keychain()
}

extension Global {
    var hasGMusicToken: Bool {
        return keychain.accessToken != nil
    }
    
    var gMusicToken: GMusicToken? {
        guard let token = keychain.accessToken else { return nil }
        return GMusicToken(accessToken: token,
                           expiresIn: keychain.expiresIn,
                           refreshToken: keychain.refreshToken)
    }
    
    func saveInKeychain(token: GMusicToken) {
        keychain.accessToken = token.accessToken
        keychain.expiresIn = token.expiresIn ?? 0
        keychain.refreshToken = token.refreshToken
    }
    
    func clearKeychainToken() {
        keychain.accessToken = nil
        keychain.expiresIn = 0
        keychain.refreshToken = nil
    }
}
