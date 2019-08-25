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
            @unknown default: fatalError()
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

final class Player<Item> {
    struct Percent: ExpressibleByFloatLiteral {
        typealias FloatLiteralType = Double
        
        let rawValue: FloatLiteralType
        
        init(floatLiteral value: Double) {
            switch value {
            case let v where v >= 0 && v <= 100: rawValue = v / 100
            default: rawValue = 0
            }
        }
    }
    
    private let bag = DisposeBag()
    
    private let avPlayer: AVPlayer
    private let createDownloadRequest: (Item, ClosedRange<Int>?) -> Single<URLRequest>
    
    private let errorSubject = PublishSubject<Error>()
    lazy var errors: Observable<Error> = {
        return errorSubject.asObservable().share(replay: 0, scope: .whileConnected)
    }()

    private let timerSubject = PublishSubject<Void>()
    lazy private(set) var timer: Observable<Void> = { return timerSubject.asObservable().share(replay: 1, scope: .whileConnected) }()
    private var timerDisposable: Disposable? = nil
    
    private let isPlayingSubject = BehaviorSubject(value: false)
    private(set) lazy var isPlaying: Observable<Bool> = { return isPlayingSubject.asObservable().distinctUntilChanged().share(replay: 1, scope: .whileConnected) }()
    
    lazy private(set) var currentItemTime: Observable<Double?> = {
        return timer
            .withLatestFrom(seekingTo) { $1 }
            .map { [weak avPlayer = self.avPlayer] seekTime in seekTime ?? avPlayer?.currentTime().seconds }
            .share(replay: 1, scope: .whileConnected)
    }()
    
    lazy private(set) var currentItemStatus: Observable<AVPlayer.ItemStatus?> = {
        return timer.map { [weak avPlayer = self.avPlayer] _ in avPlayer?.currentItemStatus }.startWith(nil).distinctUntilChanged().share(replay: 1, scope: .whileConnected)
    }()
    
    private let seekingToSubject = BehaviorSubject<Double?>(value: nil)
    lazy private(set) var seekingTo: Observable<Double?> = {
        return seekingToSubject.asObservable().share(replay: 1, scope: .whileConnected)
    }()
    
    lazy private(set) var currentItemDuration: Observable<Double?> = {
        return timer.map { [weak avPlayer = self.avPlayer] _ in avPlayer?.currentItem?.duration.seconds }.share(replay: 1, scope: .whileConnected)
    }()
    
    lazy private(set) var currentItemProgress: Observable<Int?> = {
        return currentItemTime.withLatestFrom(currentItemDuration) { time, duration -> Int? in
            guard let t = time, !t.isNaN, !t.isInfinite else { return nil }
            guard let d = duration, !d.isNaN, !d.isInfinite else { return nil }
            return Int((t / d) * 100)
            }.distinctUntilChanged().share(replay: 1, scope: .whileConnected)
    }()
    
    init(createDownloadRequest: @escaping (Item, ClosedRange<Int>?) -> Single<URLRequest>) {
        self.createDownloadRequest = createDownloadRequest
        avPlayer = AVPlayer(playerItem: nil)
        avPlayer.automaticallyWaitsToMinimizeStalling = false
    }
    
    deinit {
        print("Player deinit")
    }
}

extension Player {
    var isFlushed: Bool {
        return avPlayer.currentItem == nil
    }
    
    var isPlayingNow: Bool {
        return (try? isPlayingSubject.value()) ?? false
    }
    
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
        isPlayingSubject.onNext(false)
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
    
    func seek(to percent: Double) {
        seek(to: Percent(floatLiteral: percent))
    }
    
    func seek(to percent: Percent) {
        guard let item = avPlayer.currentItem else { return }
        
        let newSeconds = item.duration.seconds * percent.rawValue
        seekingToSubject.onNext(newSeconds)
        
        avPlayer.seek(to: CMTime(seconds: newSeconds, preferredTimescale: 500)) { [weak self] _ in
            self?.seekingToSubject.onNext(nil)
        }
    }
    
    func play(_ track: Item?) {
        guard let track = track else {
            stop()
            return
        }
        
        avPlayer.flush()
        
        isPlayingSubject.onNext(true)
        startTimer()
        
        Single.just(ByteRangeDataAssetLoader(type: .aac, errors: errorSubject, createRequest: track |> (createDownloadRequest |> curry)))
            .map(setAsset(for: avPlayer))
            .do(onSuccess: { $0.set(rate: .play) })
            .subscribe()
            .disposed(by: bag)
    }
}

private extension Player {
    func startTimer() {
        stopTimer()
        let scheduler = SerialDispatchQueueScheduler(qos: .userInitiated)
        timerDisposable = Observable<Int>.timer(.seconds(1), period: .milliseconds(300), scheduler: scheduler)
            .map { _ in return () }.bind(to: timerSubject)
    }
    
    func stopTimer() {
        timerDisposable?.dispose()
        timerDisposable = nil
    }
}

extension Player: CustomStringConvertible {
    var description: String {
        return "isFlushed \(isFlushed), isPlayingNow \(isPlayingNow)"
    }
}
