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
    @objc dynamic var currentDuration: String? = nil
    @objc dynamic var palyPauseImage: NSImage = NSImage(imageLiteralResourceName: "Pause")
    
    let isPlayingRelay = BehaviorRelay(value: false)
    lazy var isPlaying: Observable<Bool> = { return isPlayingRelay.asObservable().share() }()
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
    }
    
    func bind() {
        Global.current.dataFlowController.state.observeOn(MainScheduler.instance).do(onNext: { [weak self] result in
            if case PlayerAction.loadRadioStationFeed = result.setBy { self?.resetQueue() }
        }) .subscribe().disposed(by: bag)
        
        isPlaying
            .observeOn(MainScheduler.instance)
            .do(onNext: { [weak self] in
                self?.palyPauseImage = $0 ? NSImage.pause : NSImage.play
                self?.playPauseButon.state = $0 ? NSControl.StateValue.off : NSControl.StateValue.on
            })
            .subscribe()
            .disposed(by: bag)

//        playPauseButon.rx.tap
//            .do(onNext: { [weak self] in self?.togglePlayPause() })
//            .subscribe()
//            .disposed(by: bag)
        playPauseButon.rx.tap
            .do(onNext: { [weak player] in player?.playNext() })
            .subscribe()
            .disposed(by: bag)
        
        nextButton.rx.tap
            .do(onNext: { [weak player] in player?.playNext() })
            .subscribe()
            .disposed(by: bag)
        
        previousButton.rx.tap
            .do(onNext: { [weak player] in player?.playPrevious() })
            .subscribe()
            .disposed(by: bag)
        
        player.currentItemStatus
            .do(onNext: { print("ItemStatus: \($0)") })
            .subscribe()
            .disposed(by: bag)
        
        player.currentTrack
            .observeOn(MainScheduler.instance)
            .do(onNext: { [weak self] in self?.update(with: $0) })
            .subscribe()
            .disposed(by: bag)
        
        player.currentItemTime
            .observeOn(MainScheduler.instance)
            .do(onNext: { [weak self] in self?.currentTime = $0?.timeString })
            .subscribe()
            .disposed(by: bag)
        
        player.currentItemDuration
            .observeOn(MainScheduler.instance)
            .do(onNext: { [weak self] in self?.currentDuration = $0?.timeString })
            .subscribe()
            .disposed(by: bag)
        
        player.currentItemProgress
            .observeOn(MainScheduler.instance)
            .do(onNext: { [weak self] in self?.currentProgress = $0?.asNsDecimalNumber })
            .subscribe()
            .disposed(by: bag)
    }
    
    func togglePlayPause() {
        isPlayingRelay.accept(!isPlayingRelay.value)
    }
    
    static func onError(_ error: Error) {
        print(error)
    }
    
    func resetQueue() {
        player.resetQueue(new: Global.current.dataFlowController.currentState.state.tracks)
    }
    
    func update(with track: GMusicTrack?) {
        currentTrackTitle = track?.title
        currentArtistAndAlbum = track == nil ? nil : "\(track!.album) (\(track!.artist))"
    }
    
    deinit {
        print("PlayerController deinit")
    }
}
