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
    @IBOutlet weak var trackDurationLabel: NSTextField!
    
    @IBOutlet weak var songProgressIndication: NSProgressIndicator!
    @IBOutlet weak var volumeSlider: NSSlider!
    
    @IBOutlet weak var showQueueButton: NSButton!
    
    @objc dynamic var currentTrackTitle: String? = nil
    @objc dynamic var currentArtistAndAlbum: String? = nil
    @objc dynamic var currentTime: String? = nil
    @objc dynamic var currentProgress: NSDecimalNumber? = nil
    @objc dynamic var currentVolume: NSDecimalNumber = 100 {
        didSet {
            player?.volume = currentVolume.floatValue / 100
        }
    }
    @objc dynamic var currentDuration: String? = nil
    @objc dynamic var palyPauseImage = NSImage.pause
    
    let bag = DisposeBag()
    var player: Player<GMusicTrack>? { return Global.current.dataFlowController.currentState.state.player }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player?.volume = currentVolume.floatValue / 100

        bag.insert(bind())
        
        subscribeToNotifications()
    }
    
    func bind() -> [Disposable] {
        return [
            Global.current.dataFlowController.currentTrack.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] in self?.update(with: $0?.track) }),
            shuffleButton.rx.tap.subscribe(onNext: { Global.current.dataFlowController.dispatch(PlayerAction.pause) }),
            previousButton.rx.tap.subscribe(onNext: { Global.current.dataFlowController.dispatch(PlayerAction.playPrevious) }),
            playPauseButon.rx.tap.subscribe(onNext: { Global.current.dataFlowController.dispatch(PlayerAction.toggle) }),
            nextButton.rx.tap.subscribe(onNext: { Global.current.dataFlowController.dispatch(PlayerAction.playNext) }),
            repeatModeButton.rx.tap.subscribe(onNext: { Global.current.dataFlowController.dispatch(PlayerAction.resume) }),
//            player?.currentItemStatus.subscribe(onNext: { print("ItemStatus: \($0)") }),
            player?.currentItemTime.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] in self?.currentTime = $0?.timeString }),
            player?.currentItemDuration.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] in self?.currentDuration = $0?.timeString }),
            player?.currentItemProgress.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] in self?.currentProgress = $0?.asNsDecimalNumber }),
            player?.isPlaying.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] in self?.palyPauseImage = $0 ? NSImage.pause : NSImage.play })
            ].compactMap { $0 }
    }
    
    func update(with track: GMusicTrack?) {
        currentTrackTitle = track?.title
        currentArtistAndAlbum = track == nil ? nil : "\(track!.album) (\(track!.artist))"
        
        Global.current.image(for: track)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in self?.albumImage.image = $0 })
            .disposed(by: bag)
        
        if Global.current.dataFlowController.currentState.state.queue.isCompleted {
            Global.current.dataFlowController.dispatch(CompositeActions.repeatFromQueueSource())
        }
    }
    
    @IBAction func queueButtonClicked(_ sender: Any) {
        Global.current.dataFlowController.dispatch(UIAction.showQueuePopover(showQueueButton))
    }
    
    func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playbackStalled), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(errorLogEntry), name: NSNotification.Name.AVPlayerItemNewErrorLogEntry, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(failedToPlayToEnd), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: nil)
    }
    
    @objc func didPlayToEnd() {
        Global.current.dataFlowController.dispatch(PlayerAction.playNext)
        print("didPlayToEnd")
    }
    
    @objc func playbackStalled() {
        Global.current.dataFlowController.dispatch(PlayerAction.pause)
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
