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

private func setAsset(for player: AVPlayer) -> (Single<URL>) -> Completable {
    return { request in
        return request.flatMapCompletable { [weak player] file in
            guard let p = player else { return .empty() }
            let asset = AVURLAsset(url: file)
            let item = AVPlayerItem(asset: asset)
            p.replaceCurrentItem(with: item)
            return .empty()
        }
    }
}

extension PrimitiveSequence where Trait == CompletableTrait {
    static func doAfter(_ completion: Completable) -> (Completable) -> Completable {
        return { work in
            return work.andThen(completion)
        }
    }
}

extension AVPlayer {
    enum Rate: Float {
        case pause = 0
        case play = 1
    }
    
    var currentItemStatus: Player.Status? {
        guard let s = currentItem?.status else { return nil }
        return Player.Status(raw: s)
    }
    
    func set(rate: AVPlayer.Rate) {
        self.rate = rate.rawValue
    }
    
    func flush() {
        set(rate: .pause)
        replaceCurrentItem(with: nil)
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
    
    let timerSubject = PublishSubject<Void>()
    lazy var timer: Observable<Void> = { return timerSubject.asObservable().share() }()
    var timerDisposable: Disposable? = nil
    var currentItemTime: Observable<Double?> {
        return timer.map { [weak avPlayer] _ in avPlayer?.currentTime().seconds }
    }
    var currentItemStatus: Observable<Player.Status?> {
        return timer.map { [weak avPlayer] _ in avPlayer?.currentItemStatus }.distinctUntilChanged()
    }
    var currentItemDuration: Observable<Double?> {
        return timer.map { [weak avPlayer] _ in avPlayer?.currentItem?.duration.seconds }
        
    }
    var currentItemProgress: Observable<Int?> {
        return currentItemTime.withLatestFrom(currentItemDuration) { time, duration -> Int? in
            guard let t = time, !t.isNaN, !t.isInfinite else { return nil }
            guard let d = duration, !d.isNaN, !d.isInfinite else { return nil }
            return Int((t / d) * 100)
        }.distinctUntilChanged()
    }
    
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
        
        startTimer()
        
        return track
            |> loadRequest
            >>> saveTrack(to: rootPath.randomAac)
            >>> setAsset(for: avPlayer)
            >>> Completable.doAfter(set(rate: .play))
    }
    
    private func set(rate: AVPlayer.Rate) -> Completable {
        avPlayer.set(rate: rate)
        return .empty()
    }
    
    func resetQueue(new items: [GMusicTrack]) {
        currentTrackIndex = -1
        queue = items
    }
    
    deinit {
        print("Player deinit")
    }
}

private extension Player {
    func startTimer() {
        stopTimer()
        let scheduler = SerialDispatchQueueScheduler(qos: .userInitiated)
        timerDisposable = Observable<Int>.timer(1.0, period: 0.5, scheduler: scheduler).map { _ in return () }.bind(to: timerSubject)
    }
    
    func stopTimer() {
        timerDisposable?.dispose()
        timerDisposable = nil
    }
}
