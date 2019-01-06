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
    case PlayerAction.loadRadioStationFeed(let station): return loadRadioStationFeed(station, currentState: currentState, client: client)
    case PlayerAction.loadRadioStations: return loadRadioStations(client: client)
    case PlayerAction.pause: currentState.player?.pause()
    case PlayerAction.resume: currentState.player?.resume()
    case PlayerAction.playNext: return playNext(currentState: currentState)
    case PlayerAction.playPrevious: return playPrevious(currentState: currentState)
    case PlayerAction.toggle: currentState.player?.toggle()
    default: break
    }
    return RxReduceResult.empty
}

private func playPrevious(currentState: AppState) -> RxReduceResult<AppState> {
    var queue = currentState.queue
    let track = queue.previous()
    currentState.player?.play(track)
    return RxReduceResult.single { $0.mutate(\.queue, queue) }
}

private func playNext(currentState: AppState) -> RxReduceResult<AppState> {
    var queue = currentState.queue
    let track = queue.next()
    currentState.player?.play(track)
    return RxReduceResult.single { $0.mutate(\.queue, queue) }
}

private func loadRadioStationFeed(_ station: GMusicRadioStation, currentState: AppState, client: GMusicClient) -> RxReduceResult<AppState> {
    
    return RxReduceResult.create(from: client.radioStationFeed(for: station, maxResults: 100),
                                 transform: { $0.mutate(\.queue, Queue(items: $1.items.first?.tracks ?? [])) })
}

private func loadRadioStations(client: GMusicClient) -> RxReduceResult<AppState> {
    let request = client.radioStations(maxResults: 100, recursive: true)
        .map { $0.items.filter { $0.inLibrary } }
        .reduce([GMusicRadioStation](), accumulator: { $0 + $1 })
    return RxReduceResult.create(from: request, transform: { $0.mutate(\AppState.radioStations, $1) })
}
