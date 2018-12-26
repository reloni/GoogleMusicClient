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
                        queue: [])
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
    }
    
    func bind() {
        Global.current.dataFlowController.state.observeOn(MainScheduler.instance).do(onNext: { [weak self] result in
            if case PlayerAction.loadRadioStationFeed = result.setBy { self?.resetQueue() }
        }) .subscribe().disposed(by: bag)
        
        playPauseButon.rx.tap
            .flatMap { [weak player] in player?.playNext().asObservable() ?? .empty() }
            .do(onError: PlayerController.onError)
            .retry()
            .subscribe()
            .disposed(by: bag)
    }
    
    static func onError(_ error: Error) {
        print(error)
    }
    
    func resetQueue() {
        player.resetQueue(new: Global.current.dataFlowController.currentState.state.tracks)
    }
    
//    func update() {
//        guard let track = Global.current.dataFlowController.currentState.state.tracks.first else { return }
//        songTitleLabel.stringValue = track.title
//        artistAndAlbumLabel.stringValue = "\(track.album) (\(track.artist))"
//    }
    
    deinit {
        print("PlayerController deinit")
    }
}
