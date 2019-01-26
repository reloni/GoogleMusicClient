//
//  PlayerController.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 19/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa
import RxGoogleMusic
import RxSwift
import RxCocoa
import RxDataFlow
import AVFoundation

final class PlayerController: NSViewController {
    @IBOutlet weak var albumImage: NSImageView!
    @IBOutlet weak var songTitleLabel: NSTextField!
    @IBOutlet weak var artistAndAlbumLabel: NSTextField!
    
    @IBOutlet weak var shuffleButton: NSButton!
    @IBOutlet weak var previousButton: NSButton!
    @IBOutlet weak var playPauseButon: NSButton!
    @IBOutlet weak var nextButton: NSButton!
    @IBOutlet weak var repeatModeButton: NSButton!
    
    @IBOutlet weak var queueButton: NSButton!
    
    @IBOutlet weak var currentTimeLabel: NSTextField!
    @IBOutlet weak var currentProgressSlider: ApplicationSlider!
    @IBOutlet weak var trackDurationLabel: NSTextField!
    
    @IBOutlet weak var volumeSlider: NSSlider!
    
    @IBOutlet weak var showQueueButton: NSButton!
    
    
    
    @objc dynamic var currentTrackTitle: String? = nil
    @objc dynamic var currentArtistAndAlbum: String? = nil
    @objc dynamic var currentTime: String? = nil
    @objc dynamic var currentProgress: NSDecimalNumber? = nil
    @objc dynamic var isCurrentProgressChangeEnabled = false
    @objc dynamic var currentVolume: NSDecimalNumber = 100 {
        didSet {
            player?.volume = currentVolume.floatValue / 100
        }
    }
    @objc dynamic var currentDuration: String? = nil
    @objc dynamic var palyPauseImage = NSImage.pause
    
    let bag = DisposeBag()
    var player: Player<GMusicTrack>? { return Current.currentState.state.player }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player?.volume = currentVolume.floatValue / 100

        bag.insert(bind())
        
        subscribeToNotifications()
    }
    
    func bind() -> [Disposable] {
        return [
            Current.currentTrack.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] in self?.update(with: $0?.track) }),
            shuffleButton.rx.tap.subscribe(onNext: { Current.dispatch(PlayerAction.pause) }),
            previousButton.rx.tap.subscribe(onNext: { Current.dispatch(PlayerAction.playPrevious) }),
            playPauseButon.rx.tap.subscribe(onNext: { Current.dispatch(PlayerAction.toggle) }),
            nextButton.rx.tap.subscribe(onNext: { Current.dispatch(PlayerAction.playNext) }),
            repeatModeButton.rx.tap.subscribe(onNext: { Current.dispatch(PlayerAction.resume) }),
//            player?.currentItemStatus.subscribe(onNext: { print("ItemStatus: \($0)") }),
            player?.currentItemTime.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] in self?.currentTime = $0?.timeString }),
            player?.currentItemDuration.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] in self?.currentDuration = $0?.timeString }),
            player?.isPlaying.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] in self?.palyPauseImage = $0 ? NSImage.pause : NSImage.play }),
            currentProgressSlider.userSetValue.subscribe(onNext: { Current.currentState.state.player?.seek(to: $0) }),
            Current.currentTrack.map { $0 != nil }.subscribe(onNext: { [weak self] in self?.isCurrentProgressChangeEnabled = $0 }),
            player?.errors.subscribe(onNext: { Current.dispatch(UIAction.showErrorController($0)) }),
            bindProgress()
            ].compactMap { $0 }
    }
    
    func bindProgress() -> Disposable? {
        return player?.currentItemProgress
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] progress in
                if self?.currentProgressSlider.isUserInteracting == false {
                    self?.currentProgress = progress?.asNsDecimalNumber
                }
            })
    }
    
    func update(with track: GMusicTrack?) {
        currentTrackTitle = track?.title
        currentArtistAndAlbum = track == nil ? nil : "\(track!.album) (\(track!.artist))"
        
        image(for: track)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in self?.albumImage.image = $0 })
            .disposed(by: bag)
        
        if Current.currentState.state.queue.isCompleted {
            Current.dispatch(CompositeActions.repeatFromQueueSource())
        }
    }
    
    func image(for track: GMusicTrack?) -> Observable<NSImage> {
        guard let client = Current.currentState.state.client else { return Observable.just(NSImage.album) }
        guard let track = track else { return Observable.just(NSImage.album) }
        
        return client
            .downloadAlbumArt(track)
            .catchErrorJustReturn(nil)
            .map { NSImage($0) ?? NSImage.album }
            .asObservable()
            .startWith(NSImage.album)
    }
    
    @IBAction func queueButtonClicked(_ sender: Any) {
        Current.dispatch(UIAction.showQueuePopover(showQueueButton))
    }
    
    func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playbackStalled), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(errorLogEntry), name: NSNotification.Name.AVPlayerItemNewErrorLogEntry, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(failedToPlayToEnd), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: nil)
    }
    
    @objc func didPlayToEnd() {
        Current.dispatch(PlayerAction.playNext)
        print("didPlayToEnd")
    }
    
    @objc func playbackStalled() {
        Current.dispatch(PlayerAction.pause)
        print("playbackStalled")
    }
    
    @objc func errorLogEntry() {
        print("playbackStalled")
    }
    
    @objc func failedToPlayToEnd() {
        print("playbackStalled")
    }

    deinit {
        print("PlayerController deinit")
    }
}
