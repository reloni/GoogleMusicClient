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

private func setAsset(for player: AVPlayer) -> (AVAssetResourceLoaderDelegate) -> AVPlayer {
    return { assetLoader in
        player.replaceCurrentItem(with: nil)
        
        let asset = AVURLAsset(url: URL(string: "dummy://domain.com/some.file")!)
        asset.resourceLoader.setDelegate(assetLoader, queue: DispatchQueue.global(qos: .default))
        
        // make strong reference between asset and loader delegate
        // in order to prevent delegate deallocation
        var handle = 0
        objc_setAssociatedObject(asset, &handle, assetLoader, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
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

struct Queue<Element> {
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
    
    private mutating func incrementIndex() {
        currentIndex = currentIndex.incremented(maxValue: items.count)
    }
    
    private mutating func decrementIndex() {
        currentIndex = currentIndex.decremented(maxValue: items.count)
    }
    
    mutating func next() -> Element? {
        incrementIndex()
        return current
    }
    
    mutating func previous() -> Element? {
        decrementIndex()
        return current
    }
    
    mutating func shuffle() {
        items = items.shuffled()
        currentIndex = .notStarted
    }
    
    mutating func append(items: [Element]) {
        self.items += items
        if currentIndex == .completed {
            currentIndex = .index(self.items.count - items.count)
        }
    }
    
    mutating func resetIndex() {
        currentIndex = .notStarted
    }
    
    mutating func setIndex(to newIndex: Int) -> Element? {
        guard 0..<items.count ~= newIndex else { return nil }
        currentIndex = .index(newIndex)
        return current
    }
    
    mutating func replace(withNew items: [Element]) {
        self.items = items
        currentIndex = .notStarted
    }
}

final class Player<Item> {
    private let bag = DisposeBag()
    
    private let avPlayer: AVPlayer
    private let loadRequest: (Item) -> Single<Data>

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
    
    init(loadRequest: @escaping (Item) -> Single<Data>) {
        self.loadRequest = loadRequest
        avPlayer = AVPlayer(playerItem: nil)
    }
    
    deinit {
        print("Player deinit")
    }
}

extension Player {
    var volume: Float {
        get { return avPlayer.volume }
        set { avPlayer.volume = newValue }
    }
    
    func pause() {
        avPlayer.set(rate: .pause)
        isPlayingSubject.onNext(false)
        stopTimer()
    }
    
    func stop() {
        avPlayer.flush()
        isPlayingSubject.onNext(true)
    }
    
    func resume() {
        guard avPlayer.currentItem != nil else {
            isPlayingSubject.onNext(false)
            return
        }
        
        avPlayer.set(rate: .play)
        isPlayingSubject.onNext(true)
        startTimer()
    }
    
    func toggle() {
        Observable
            .combineLatest(isPlaying.single(), Observable.just(self), resultSelector: { ($0, $1) })
            .subscribe(onNext: { $0 ? $1.pause() : $1.resume() })
            .disposed(by: bag)
    }
    
    func play(_ track: Item?) {
        guard let track = track else {
            avPlayer.flush()
            isPlayingSubject.onNext(false)
            return
        }
        
        isPlayingSubject.onNext(true)
        startTimer()
        
        loadRequest(track)
            .map { DataAssetLoader($0, type: .aac) }
            .map(setAsset(for: avPlayer))
            .do(onSuccess: { $0.set(rate: .play) })
            .do(onError: { print("player error: \($0)") })
            .subscribe()
            .disposed(by: bag)
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

