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
    
    let player = Player(rootPath: Global.current.musicDirectory,
                        loadRequest: Global.current.dataFlowController.currentState.state.client!.downloadTrack,
                        items: [])
    
    @objc dynamic var currentTrackTitle: String? = nil
    @objc dynamic var currentArtistAndAlbum: String? = nil
    @objc dynamic var currentTime: String? = nil
    @objc dynamic var currentProgress: NSDecimalNumber? = nil
    @objc dynamic var currentVolume: NSDecimalNumber = 100 {
        didSet {
            player.volume = currentVolume.floatValue / 100
        }
    }
    @objc dynamic var currentDuration: String? = nil
    @objc dynamic var palyPauseImage = NSImage(imageLiteralResourceName: "Pause")
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player.volume = currentVolume.floatValue / 100

        bag.insert(bind())
    }
    
    func bind() -> [Disposable] {
        return [
            Global.current.dataFlowController.state.subscribe(onNext: { [weak self] in self?.handle($0.setBy) }),
            shuffleButton.rx.tap.subscribe(onNext: { [weak player] in player?.pause() }),
            previousButton.rx.tap.subscribe(onNext: { [weak player] in player?.playPrevious() }),
            playPauseButon.rx.tap.subscribe(onNext: { [weak player] in player?.toggle() }),
            nextButton.rx.tap.subscribe(onNext: { [weak player] in player?.playNext() }),
            repeatModeButton.rx.tap.subscribe(onNext: { [weak player] in player?.resume() }),
            player.currentItemStatus.subscribe(onNext: { print("ItemStatus: \($0)") }),
            player.currentTrack.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] in self?.update(with: $0) }),
            player.currentItemTime.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] in self?.currentTime = $0?.timeString }),
            player.currentItemDuration.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] in self?.currentDuration = $0?.timeString }),
            player.currentItemProgress.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] in self?.currentProgress = $0?.asNsDecimalNumber }),
            player.isPlaying.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] in self?.palyPauseImage = $0 ? NSImage.pause : NSImage.play })
        ]
    }
    
    func handle(_ action: RxActionType) {
        if case PlayerAction.loadRadioStationFeed = action {
            player.resetQueue(new: Global.current.dataFlowController.currentState.state.tracks)
        }
    }
    
    func update(with track: GMusicTrack?) {
        currentTrackTitle = track?.title
        currentArtistAndAlbum = track == nil ? nil : "\(track!.album) (\(track!.artist))"
    }
    
    deinit {
        print("PlayerController deinit")
    }
}
