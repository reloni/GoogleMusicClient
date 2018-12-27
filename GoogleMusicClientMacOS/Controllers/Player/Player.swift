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

private func saveTrack(to path: URL) -> (Data) throws -> URL {
    return { data in
        try writeData(data, to: path)
        return path
    }
}

private func setAsset(for player: AVPlayer) -> (URL) -> AVPlayer {
    return { file in
        let asset = AVURLAsset(url: file)
        let item = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: item)
        return player
    }
}

extension AVPlayer {
    enum ItemStatus {
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
    
    enum Rate: Float {
        case pause = 0
        case play = 1
    }
    
    var currentItemStatus: AVPlayer.ItemStatus? {
        guard let s = currentItem?.status else { return nil }
        return AVPlayer.ItemStatus(raw: s)
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

final private class Queue<Element> {
    enum Index: Equatable {
        case notStarted
        case index(Int)
        case completed
        
        var value: Int? {
            guard case let .index(i) = self else { return nil }
            return i
        }
        
        func incremented(maxValue: Int) -> Index {
            switch self {
            case .notStarted: return .index(0)
            case .completed: return .completed
            case .index(let i):
                if i < maxValue - 1 {
                    return .index(i + 1)
                } else {
                    return .completed
                }
            }
        }
        
        func decremented(maxValue: Int) -> Index {
            switch self {
            case .notStarted: return .notStarted
            case .completed: return .index(maxValue - 1)
            case .index(let i):
                if i > 0 {
                    return .index(i - 1)
                } else {
                    return .notStarted
                }
            }
        }
        
        static func == (lhs: Index, rhs: Index) -> Bool {
            switch (lhs, rhs) {
            case (.notStarted, .notStarted): return true
            case (.completed, .completed): return true
            case let (.index(l), .index(r)): return l == r
            default: return false
            }
        }
    }
    
    private var items: [Element]
    private var currentIndex = Index.notStarted
    
    init(items: [Element]) {
        self.items = items
    }
    
    var current: Element? {
        guard let index = currentIndex.value else { return nil }
        return items[index]
    }
    
    var count: Int { return items.count }
    
    var currentElementIndex: Int? { return currentIndex.value }
    
    private func incrementIndex() {
        currentIndex = currentIndex.incremented(maxValue: items.count)
    }
    
    private func decrementIndex() {
        currentIndex = currentIndex.decremented(maxValue: items.count)
    }
    
    func next() -> Element? {
        incrementIndex()
        return current
    }
    
    func previous() -> Element? {
        decrementIndex()
        return current
    }
    
    func shuffle() {
        items = items.shuffled()
        currentIndex = .notStarted
    }
    
    func append(items: [Element]) {
        self.items += items
        if currentIndex == .completed {
            currentIndex = .index(self.items.count - items.count)
        }
    }
    
    func replace(withNew items: [Element]) {
        self.items = items
        currentIndex = .notStarted
    }
}

final class Player {
    private let bag = DisposeBag()
    
    private var queue = Queue<GMusicTrack>(items: [])
    private let avPlayer: AVPlayer
    private let rootPath: URL
    private let loadRequest: (GMusicTrack) -> Single<Data>
    
    private let currentTrackSubject = BehaviorSubject<GMusicTrack?>(value: nil)
    var currentTrack: Observable<GMusicTrack?> { return currentTrackSubject.distinctUntilChanged { $0?.identifier == $1?.identifier } }
    
    private let timerSubject = PublishSubject<Void>()
    lazy private(set) var timer: Observable<Void> = { return timerSubject.asObservable().share() }()
    private var timerDisposable: Disposable? = nil
    
    init(rootPath: URL, loadRequest: @escaping (GMusicTrack) -> Single<Data>, items: [GMusicTrack]) {
        self.rootPath = rootPath
        self.loadRequest = loadRequest
        avPlayer = AVPlayer(playerItem: nil)
        queue.append(items: items)
    }
    
    func playNext() {
        let track = queue.next()
        currentTrackSubject.onNext(track)
        play(track)
    }
    
    func playPrevious() {
        let track = queue.previous()
        currentTrackSubject.onNext(track)
        play(track)
    }
    
    private func play(_ track: GMusicTrack?) {
        guard let track = track else { return }
        
        startTimer()
        
        loadRequest(track)
            .map(saveTrack(to: rootPath.randomAac))
            .map(setAsset(for: avPlayer))
            .do(onSuccess: { $0.set(rate: .play) })
            .do(onError: { print("player error: \($0)") })
            .subscribe()
            .disposed(by: bag)
    }
    
    func pause() {
        avPlayer.set(rate: .pause)
        stopTimer()
    }
    
    func resume() {
        avPlayer.set(rate: .pause)
        startTimer()
    }
    
    func resetQueue(new items: [GMusicTrack]) {
        queue.replace(withNew: items)
    }
    
    deinit {
        print("Player deinit")
    }
}

extension Player {
    var currentItemTime: Observable<Double?> { return timer.map { [weak avPlayer] _ in avPlayer?.currentTime().seconds } }
    var currentItemStatus: Observable<AVPlayer.ItemStatus?> { return timer.map { [weak avPlayer] _ in avPlayer?.currentItemStatus }.startWith(nil).distinctUntilChanged() }
    var currentItemDuration: Observable<Double?> { return timer.map { [weak avPlayer] _ in avPlayer?.currentItem?.duration.seconds } }
    
    var currentItemProgress: Observable<Int?> {
        return currentItemTime.withLatestFrom(currentItemDuration) { time, duration -> Int? in
            guard let t = time, !t.isNaN, !t.isInfinite else { return nil }
            guard let d = duration, !d.isNaN, !d.isInfinite else { return nil }
            return Int((t / d) * 100)
            }.distinctUntilChanged()
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
