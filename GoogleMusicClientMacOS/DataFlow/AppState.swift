//
//  AppState.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 14/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import RxDataFlow
import RxGoogleMusic

struct AppState: RxStateType {
    private(set) var coordinator: ApplicationCoordinator
    let keychain: KeychainType
    private(set) var client: GMusicClient?
    private(set) var radioStations: [GMusicRadioStation]
    private(set) var player: Player<GMusicTrack>?
    private(set) var queue: Queue<GMusicTrack>
}

extension AppState {
    func cleaned() -> AppState {
        return  AppState.init(coordinator: coordinator,
                              keychain: keychain,
                              client: nil,
                              radioStations: [],
                              player: nil,
                              queue: Queue(items: []))
    }
    
    func mutate<Value>(_ kp: WritableKeyPath<AppState, Value>, _ v: Value) -> AppState {
        var copy = self
        copy[keyPath: kp] = v
        return copy
    }
    
    var gMusicToken: GMusicToken? {
        guard let token = keychain.accessToken else { return nil }
        return GMusicToken(accessToken: token,
                           expiresAt: keychain.expiresAt,
                           refreshToken: keychain.refreshToken)
    }
    
    var hasGmusicToken: Bool { return keychain.accessToken != nil }
    
    var currentTrack: (track: GMusicTrack, index: Int)? {
        guard let t = queue.current, let i = queue.currentElementIndex else { return nil }
        return (t, i)
    }
}
