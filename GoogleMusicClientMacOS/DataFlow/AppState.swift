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
    let keychain: KeychainType
}
