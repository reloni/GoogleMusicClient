//
//  AppState.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 14/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import RxDataFlow
import RxGoogleMusic

enum QueueSource: Equatable {
    case radio(GMusicRadioStation)
    case list([GMusicTrack])
    
    var isFavorites: Bool {
        if case .list = self {
            return true
        }
        return false
    }
}

struct AppState: RxStateType {
    private(set) var coordinator: ApplicationCoordinator
    let keychain: KeychainType
    private(set) var client: GMusicClient?
    private(set) var radioStations: [GMusicRadioStation]
    private(set) var favorites: [GMusicTrack]
    private(set) var player: Player<GMusicTrack>?
    private(set) var queue: Queue<GMusicTrack>
    private(set) var queueSource: QueueSource?
}

func initialState() -> AppState {
    return AppState(coordinator: StartupCoordinator(),
                    keychain: Keychain(),
                    client: nil,
                    radioStations: [],
                    favorites: [],
                    player: nil,
                    queue: Queue(items: [GMusicTrack]()),
                    queueSource: nil)
}

extension AppState {
    func cleaned() -> AppState {
        return  AppState(coordinator: coordinator,
                              keychain: keychain,
                              client: nil,
                              radioStations: [],
                              favorites: [],
                              player: nil,
                              queue: Queue(items: []),
                              queueSource: nil)
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
    
    var currentTrack: (track: GMusicTrack, index: Int, source: QueueSource)? {
        guard let t = queue.current, let i = queue.currentElementIndex, let s = queueSource else { return nil }
        return (t, i, s)
    }
}
