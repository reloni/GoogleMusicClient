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
    guard let client = currentState.client else { return RxReduceResult.empty }
    
    switch action {
    case PlayerAction.loadRadioStationFeed(let station): return loadRadioStation(station, currentState: currentState, client: client)
    case PlayerAction.loadRadioStations: return loadRadioStations(client: client)
    default: break
    }
    return RxReduceResult.empty
}

private func loadRadioStation(_ station: GMusicRadioStation, currentState: AppState, client: GMusicClient) -> RxReduceResult<AppState> {
    return RxReduceResult.create(from: client.radioStationFeed(for: station),
                                 transform: { $0.mutate(\AppState.tracks, $1.items.first?.tracks ?? []) })
}

private func loadRadioStations(client: GMusicClient) -> RxReduceResult<AppState> {
    return RxReduceResult.create(from: client.radioStations(maxResults: 25, recursive: true).map { $0.items }.reduce([GMusicRadioStation](), accumulator: { $0 + $1 }),
                                 transform: { $0.mutate(\AppState.radioStations, $1) })
}
