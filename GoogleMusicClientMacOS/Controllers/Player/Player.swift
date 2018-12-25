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

private func newTrackFile() -> URL {
    return Global.current.musicDirectory.appendingPathComponent("\(UUID().uuidString).aac")
}

private func download(track: GMusicTrack, using client: GMusicClient) -> Single<Data> {
    guard let id = (track.nid ?? track.id?.uuidString) else { fatalError("No nid and id ¯\\_(ツ)_/¯") }
    return client.downloadTrack(id: id)
}

private func saveTrack(to path: URL) -> (Single<Data>) -> Single<URL> {
    return { data in
        return data.flatMap { data in try writeData(data, to: path); return .just(path) }
    }
}

private func playTrack(with player: AVPlayer) -> (Single<URL>) -> Completable {
    return { url in
        return .empty()
    }
}

final class Player {
    
    private let bag = DisposeBag()
    
    private let queue: [GMusicTrack]
    private let avPlayer: AVPlayer
    private var currentTrackIndex: Int = -1
    private let rootPath: URL
    private let loadRequest: (GMusicTrack) -> Single<Data>
    
    init(rootPath: URL, loadRequest: @escaping (GMusicTrack) -> Single<Data>, queue: [GMusicTrack]) {
        self.rootPath = rootPath
        self.loadRequest = loadRequest
        self.queue = queue
        self.avPlayer = AVPlayer(playerItem: nil)
    }
    
    func playNext() -> Completable {
        currentTrackIndex += 1
        guard currentTrackIndex < queue.count else { return Completable.empty() }
        return play(track: queue[currentTrackIndex])
    }
    
    private func play(track: GMusicTrack) -> Completable {
        return track
            |> loadRequest
            >>> saveTrack(to: rootPath.randomAac)
            >>> playTrack(with: avPlayer)
    }
}
