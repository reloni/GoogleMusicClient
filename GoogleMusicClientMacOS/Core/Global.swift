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
import Cocoa

private func initialState() -> AppState {
    return AppState(coordinator: StartupCoordinator(),
                    keychain: Keychain(),
                    client: nil,
                    radioStations: [],
                    player: nil,
                    queue: Queue(items: [GMusicTrack]()),
                    queueSource: nil)
}

struct Global {
    static var current: Global = Global()    
    var dataFlowController = RxDataFlowController(reducer: rootReducer, initialState: initialState())
    func image(for track: GMusicTrack?) -> Observable<NSImage> {
        guard let client = dataFlowController.currentState.state.client else { return Observable.just(NSImage.album) }
        guard let track = track else { return Observable.just(NSImage.album) }
        
        return client
            .downloadAlbumArt(track)
            .catchErrorJustReturn(nil)
            .map { NSImage($0) ?? NSImage.album }
            .asObservable()
            .startWith(NSImage.album)
    }
}
