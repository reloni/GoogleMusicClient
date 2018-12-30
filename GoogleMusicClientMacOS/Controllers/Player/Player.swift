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

private func saveData(to path: URL) -> (Data) throws -> URL {
    return { data in
        try data.write(to: path)
        return path
    }
}

private func setAsset(for player: AVPlayer) -> (URL) -> AVPlayer {
    return { file in
        player.replaceCurrentItem(with: nil)
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
            case .notStarted: return maxValue > 0 ? .index(0) : .notStarted
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
    
    private(set) var items: [Element]
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
    
    private let currentItemSubject = BehaviorSubject<(index:Int, item: GMusicTrack)?>(value: nil)
    lazy private(set) var currentItem: Observable<((index:Int, item: GMusicTrack))?> = {
        return currentItemSubject.distinctUntilChanged { $0?.index != $1?.index && $0?.item.identifier == $1?.item.identifier }.share(replay: 1, scope: .forever)
    }()
    
    private let timerSubject = PublishSubject<Void>()
    lazy private(set) var timer: Observable<Void> = { return timerSubject.asObservable().share(replay: 1, scope: .forever) }()
    private var timerDisposable: Disposable? = nil
    
    private let isPlayingSubject = BehaviorSubject(value: false)
    private(set) lazy var isPlaying: Observable<Bool> = { return isPlayingSubject.asObservable().distinctUntilChanged().share(replay: 1, scope: .forever) }()
    
    lazy private(set) var currentItemTime: Observable<Double?> = {
        return timer.map { [weak avPlayer = self.avPlayer] _ in avPlayer?.currentTime().seconds }.share(replay: 1, scope: .whileConnected)
    }()
    
    lazy private(set) var currentItemStatus: Observable<AVPlayer.ItemStatus?> = {
        return timer.map { [weak avPlayer = self.avPlayer] _ in avPlayer?.currentItemStatus }.startWith(nil).distinctUntilChanged().share(replay: 1, scope: .forever)
    }()
    
    lazy private(set) var currentItemDuration: Observable<Double?> = {
        return timer.map { [weak avPlayer = self.avPlayer] _ in avPlayer?.currentItem?.duration.seconds }.share(replay: 1, scope: .forever)
    }()
    
    lazy private(set) var currentItemProgress: Observable<Int?> = {
        return currentItemTime.withLatestFrom(currentItemDuration) { time, duration -> Int? in
            guard let t = time, !t.isNaN, !t.isInfinite else { return nil }
            guard let d = duration, !d.isNaN, !d.isInfinite else { return nil }
            return Int((t / d) * 100)
            }.distinctUntilChanged().share(replay: 1, scope: .whileConnected)
    }()
    
    init(rootPath: URL, loadRequest: @escaping (GMusicTrack) -> Single<Data>, items: [GMusicTrack]) {
        self.rootPath = rootPath
        self.loadRequest = loadRequest
        avPlayer = AVPlayer(playerItem: nil)
        queue.append(items: items)
        subscribeToNotifications()
    }
    
    deinit {
        print("Player deinit")
    }
}

extension Player {
    var currentItemIndex: Int? {
        return queue.currentElementIndex
    }
    
    var volume: Float {
        get { return avPlayer.volume }
        set { avPlayer.volume = newValue }
    }
    
    var items: [GMusicTrack] { return queue.items }
    
    func playNext() {
        let track = queue.next()
        notifyObserversOnItemChange()
        play(track)
    }
    
    func playPrevious() {
        let track = queue.previous()
        notifyObserversOnItemChange()
        play(track)
    }
    
    func pause() {
        avPlayer.set(rate: .pause)
        isPlayingSubject.onNext(false)
        stopTimer()
    }
    
    func resume() {
        guard queue.current != nil else {
            playNext()
            return
        }
        
        avPlayer.set(rate: .play)
        isPlayingSubject.onNext(queue.current != nil)
        startTimer()
    }
    
    func resetQueue(new items: [GMusicTrack]) {
        queue.replace(withNew: items)
    }
    
    func toggle() {
        Observable
            .combineLatest(isPlaying.single(), Observable.just(self), resultSelector: { ($0, $1) })
            .subscribe(onNext: { $0 ? $1.pause() : $1.resume() })
            .disposed(by: bag)
    }
}

private extension Player {
    func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playbackStalled), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(errorLogEntry), name: NSNotification.Name.AVPlayerItemNewErrorLogEntry, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(failedToPlayToEnd), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: nil)
    }
    
    @objc func didPlayToEnd() {
        playNext()
        print("didPlayToEnd")
    }
    
    @objc func playbackStalled() {
        pause()
        print("playbackStalled")
    }
    
    @objc func errorLogEntry() {
        print("playbackStalled")
    }
    
    @objc func failedToPlayToEnd() {
        print("playbackStalled")
    }
    
    func startTimer() {
        stopTimer()
        let scheduler = SerialDispatchQueueScheduler(qos: .userInitiated)
        timerDisposable = Observable<Int>.timer(1.0, period: 0.5, scheduler: scheduler).map { _ in return () }.bind(to: timerSubject)
    }
    
    func stopTimer() {
        timerDisposable?.dispose()
        timerDisposable = nil
    }
    
    func play(_ track: GMusicTrack?) {
        guard let track = track else {
            avPlayer.flush()
            return
        }
        
        startTimer()
        
        loadRequest(track)
            .map(saveData(to: rootPath.randomAac))
            .map(setAsset(for: avPlayer))
            .do(onSuccess: { $0.set(rate: .play) })
            .do(onError: { print("player error: \($0)") })
            .subscribe()
            .disposed(by: bag)
    }
    
    func notifyObserversOnItemChange() {
        guard let item = queue.current, let index = queue.currentElementIndex else {
            currentItemSubject.onNext(nil)
            isPlayingSubject.onNext(false)
            return
        }
        currentItemSubject.onNext((index: index, item: item))
        isPlayingSubject.onNext(true)
    }
}
