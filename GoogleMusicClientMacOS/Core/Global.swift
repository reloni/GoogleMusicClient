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
    return AppState(coordinator: StartupCoordinator(),
                    keychain: Keychain(),
                    client: nil,
                    radioStations: [],
                    player: nil)
}

struct Global {
    static var current: Global = Global()    
    var dataFlowController = RxDataFlowController(reducer: rootReducer, initialState: initialState())
    
    static var musicDirectory: URL {
        let music = FileManager.default.urls(for: .musicDirectory, in: .userDomainMask).first!.appendingPathComponent("GoogleMusicPlayer")
        
        guard !FileManager.default.fileExists(atPath: music.path) else { return music }
        try! FileManager.default.createDirectory(at: music, withIntermediateDirectories: false, attributes: nil)
        return music
    }
}
