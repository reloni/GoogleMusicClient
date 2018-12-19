//
//  AppState.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 14/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import RxDataFlow

struct AppState: RxStateType {
    var coordinator: ApplicationCoordinator
    var keychain: KeychainType
}

extension AppState {
    func mutate<Value>(_ kp: WritableKeyPath<AppState, Value>, _ v: Value) -> AppState {
        let prop = property(kp)
        let mutator = prop( { _ in v } )
        return mutator(self)
    }
    
    static let noStateMutator: RxStateMutator<AppState> = { $0 }
}

private func property<Object, Value> (_ kp: WritableKeyPath<Object, Value>) -> (@escaping (Value) -> Value) -> (Object) -> Object {
    return { value in
        return { object in
            var copy = object
            copy[keyPath: kp] = value(copy[keyPath: kp])
            return copy
        }
    }
}
