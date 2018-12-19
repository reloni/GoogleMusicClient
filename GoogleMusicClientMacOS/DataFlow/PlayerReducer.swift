//
//  PlayerReducer.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 19/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation

import RxSwift
import RxDataFlow
import RxGoogleMusic

func playerReducer(_ action: RxActionType, currentState: AppState) -> RxReduceResult<AppState> {
    switch action {
    case PlayerAction.loadRadioStation(let station): return loadRadioStation(station, currentState: currentState)
    default: break
    }
    return RxReduceResult.empty
}

private func loadRadioStation(_ station: GMusicRadioStation, currentState: AppState) -> RxReduceResult<AppState> {
    guard let client = currentState.client else { return RxReduceResult.empty }
    
    return RxReduceResult.create(from: client.radioStationFeed(for: station),
                                 with: { $0.mutate(\AppState.tracks, $1.items.first!.tracks) })
}
