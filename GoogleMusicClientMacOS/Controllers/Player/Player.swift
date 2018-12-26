//
//  Player.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 25/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import RxSwift
import RxGoogleMusic
import AVFoundation

private extension URL {
    var randomAac: URL {
        return appendingPathComponent("\(UUID().uuidString).aac")
    }
}

private func writeData(_ data: Data, to url: URL) throws {
    try data.write(to: url)
}

private func saveTrack(to path: URL) -> (Single<Data>) -> Single<URL> {
    return { data in
        return data.flatMap { data in try writeData(data, to: path); return .just(path) }
    }
}

private func playTrack(with player: AVPlayer) -> (Single<URL>) -> Completable {
    return { request in
        return request.flatMapCompletable { [weak player] file in
            guard let p = player else { return .empty() }
            setAsset(from: file, with: p)
            p.rate = 1.0
            return .empty()
        }
    }
}

private func setAsset(from file: URL, with player: AVPlayer) {
    let asset = AVURLAsset(url: file)
    let item = AVPlayerItem(asset: asset)
    player.replaceCurrentItem(with: item)
}

extension AVPlayer {
    var currentItemTime: Observable<Double?> {
        return Observable<Int>.timer(1, scheduler: MainScheduler.instance).flatMap { [weak player = self] _ -> Observable<Double?> in
            return .just(player?.currentTime().seconds)
        }
    }
    
    var currentItemStatus: Observable<Player.Status?> {
        return Observable<Int>.timer(1, scheduler: MainScheduler.instance).flatMap { [weak player = self] _ -> Observable<Player.Status?>  in
            guard let i = player?.currentItem else { return .just(nil) }
            return .just(Player.Status(raw: i.status))
        }.distinctUntilChanged()
    }
}

extension GMusicTrack {
    var identifier: String {
        return nid ?? id?.uuidString ?? storeId ?? ""
    }
}

final class Player {
    enum Status {
        case failed
        case readyToPlay
        case unknown
        
        init(raw: AVPlayerItem.Status) {
            switch raw {
            case .failed: self = .failed
            case .readyToPlay: self = .readyToPlay
            case .unknown: self = .unknown
            }
        }
    }
    
    private var queue: [GMusicTrack]
    private let avPlayer: AVPlayer
    private var currentTrackIndex: Int = -1
    private let rootPath: URL
    private let loadRequest: (GMusicTrack) -> Single<Data>
    
    private let currentTrackSubject = BehaviorSubject<GMusicTrack?>(value: nil)
    var currentTrack: Observable<GMusicTrack?> {
        return currentTrackSubject.distinctUntilChanged { $0?.identifier == $1?.identifier }
    }
    var currentItemTime: Observable<Double?> { return avPlayer.currentItemTime }
    var currentItemStatus: Observable<Player.Status?> { return avPlayer.currentItemStatus }
    
    init(rootPath: URL, loadRequest: @escaping (GMusicTrack) -> Single<Data>, queue: [GMusicTrack]) {
        self.rootPath = rootPath
        self.loadRequest = loadRequest
        self.queue = queue
        self.avPlayer = AVPlayer(playerItem: nil)
    }
    
    func playNext() -> Completable {
        currentTrackIndex += 1
        guard currentTrackIndex < queue.count else {
            currentTrackSubject.onNext(nil)
            return .empty()
        }
        
        let track = queue[currentTrackIndex]
        currentTrackSubject.onNext(track)
        
        return track
            |> loadRequest
            >>> saveTrack(to: rootPath.randomAac)
            >>> playTrack(with: avPlayer)
    }
    
    func resetQueue(new items: [GMusicTrack]) {
        currentTrackIndex = -1
        queue = items
    }
}
