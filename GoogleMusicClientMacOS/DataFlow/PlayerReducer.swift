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
import GoogleMusicClientCore
import os.log

func playerReducer(_ action: RxActionType, currentState: AppState) -> RxReduceResult<AppState> {
    guard let client = currentState.client else { return RxReduceResult.empty }
    
    switch action {
    case PlayerAction.initializeQueueFromSource: return initializeQueueFromSource(currentState: currentState, client: client)
    case PlayerAction.loadRadioStations: return loadRadioStations(client: client)
    case PlayerAction.loadFavorites: return loadFavorites(client: client)
    case PlayerAction.pause: currentState.player?.pause()
    case PlayerAction.stop: currentState.player?.stop()
    case PlayerAction.resume: currentState.player?.resume()
    case PlayerAction.playNext: return playNext(currentState: currentState)
    case PlayerAction.playPrevious: return playPrevious(currentState: currentState)
    case PlayerAction.toggle: return toggle(currentState: currentState)
    case PlayerAction.playAtIndex(let index): return playAtIndex(currentState: currentState, index: index)
    case PlayerAction.setQueueSource(let s): return RxReduceResult.single { $0.mutate(\.queueSource, s) }
    case PlayerAction.shuffleQueue(let moveToFirst): return shuffleQueue(currentState: currentState, moveToFirst: moveToFirst)
    case PlayerAction.toggleShuffle:
        currentState.userDefaults.isShuffleEnabled = !currentState.userDefaults.isShuffleEnabled
        return RxReduceResult.single(id)
    case PlayerAction.toggleQueueRepeat:
        currentState.userDefaults.isRepeatQueueEnabled = !currentState.userDefaults.isRepeatQueueEnabled
        return RxReduceResult.single(id)
    default: break
    }
    return RxReduceResult.empty
}

private func toggle(currentState: AppState) -> RxReduceResult<AppState> {
    guard let player = currentState.player else {
        return .empty
    }
    
    os_log(.default, log: .player, "Will toggle player (%{public}s)", "\(player)")
    
    if player.isFlushed {
        player.play(currentState.queue.current)
    } else {
        player.toggle()
    }
    
    return .empty
}

private func shuffleQueue(currentState: AppState, moveToFirst: Int?) -> RxReduceResult<AppState> {
    var q = currentState.queue
    q.shuffle(moveToFirst: moveToFirst)
    return RxReduceResult.single { $0.mutate(\.queue, q) }
}

private func playAtIndex(currentState: AppState, index: Int) -> RxReduceResult<AppState> {
    guard currentState.queue.currentElementIndex != index else { return RxReduceResult.empty }
    var queue = currentState.queue
    let track = queue.setIndex(to: index)
    currentState.player?.play(track)
    return RxReduceResult.single { $0.mutate(\.queue, queue) }
}

private func playPrevious(currentState: AppState) -> RxReduceResult<AppState> {
    var queue = currentState.queue
    guard let track = queue.previous() else { return RxReduceResult.single(id) }
    currentState.player?.play(track)
    return RxReduceResult.single { $0.mutate(\.queue, queue) }
}

private func playNext(currentState: AppState) -> RxReduceResult<AppState> {
    var queue = currentState.queue
    let track = queue.next()
    currentState.player?.play(track)
    return RxReduceResult.single { $0.mutate(\.queue, queue) }
}

private func initializeQueueFromSource(currentState: AppState, client: GMusicClient) -> RxReduceResult<AppState> {
    guard let source = currentState.queueSource else { return RxReduceResult.single(id) }
    switch source {
    case .radio(let r): return loadRadioStationFeed(r, currentState: currentState, client: client)
    case .list(let l): return RxReduceResult.single({ $0.mutate(\.queue, Queue(items: l.all())) })
    }
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

private func loadFavorites(client: GMusicClient) -> RxReduceResult<AppState> {
    let request = client.favorites(maxResults: 10000, recursive: true)
        .map { $0.items }
        .reduce([GMusicTrack](), accumulator: { $0 + $1 })
        .map { OrderedSet(elements: $0) }
    return RxReduceResult.create(from: request, transform: { $0.mutate(\AppState.favorites, $1) })
}
