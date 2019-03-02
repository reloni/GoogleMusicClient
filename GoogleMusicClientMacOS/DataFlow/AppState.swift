//
//  AppState.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 14/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import RxDataFlow
import RxGoogleMusic

extension GMusicTrack: Hashable {
    public var hashValue: Int { return automaticId.hashValue }
    
    public func hash(into hasher: inout Hasher) {
        automaticId.hash(into: &hasher)
    }
}

enum QueueSource: Equatable {
    case radio(GMusicRadioStation)
    case list(OrderedSet<GMusicTrack>)
    
    var isFavorites: Bool {
        if case .list = self {
            return true
        }
        return false
    }
    
    var isRadio: Bool {
        if case .radio = self {
            return true
        }
        return false
    }
    
    var list: OrderedSet<GMusicTrack>? {
        guard case let .list(l) = self else { return nil }
        return l
    }
}

struct AppState: RxStateType {
    private(set) var coordinator: ApplicationCoordinator
    let keychain: KeychainType
    let userDefaults: UserDefaultsType
    private(set) var client: GMusicClient?
    private(set) var radioStations: [GMusicRadioStation]
    private(set) var favorites: OrderedSet<GMusicTrack>
    private(set) var player: Player<GMusicTrack>?
    private(set) var queue: Queue<GMusicTrack>
    private(set) var queueSource: QueueSource?
}

func initialState() -> AppState {
    return AppState(coordinator: StartupCoordinator(),
                    keychain: Keychain(),
                    userDefaults: UserDefaults.standard,
                    client: nil,
                    radioStations: [],
                    favorites: OrderedSet<GMusicTrack>(),
                    player: nil,
                    queue: Queue(items: [GMusicTrack]()),
                    queueSource: nil)
}

extension AppState {
    func cleaned() -> AppState {
        return  AppState(coordinator: coordinator,
                              keychain: keychain,
                              userDefaults: userDefaults,
                              client: nil,
                              radioStations: [],
                              favorites: OrderedSet<GMusicTrack>(),
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
    
    var currentTrack: (track: GMusicTrack, queueIndex: Int, source: QueueSource)? {
        guard let t = queue.current, let i = queue.currentElementIndex, let s = queueSource else { return nil }
        return (t, i, s)
    }
    
    var currentRadio: (radio: GMusicRadioStation, index: Int)? {
        guard case QueueSource.radio(let r)? = queueSource else { return nil }
        guard let index = radioStations.firstIndex(of: r) else { return nil }
        return (radio: r, index: index)
    }
    
    var isRepeatQueueEnabled: Bool {
        return userDefaults.isRepeatQueueEnabled
    }
}
