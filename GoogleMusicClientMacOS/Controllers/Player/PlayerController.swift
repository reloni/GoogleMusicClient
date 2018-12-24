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
import AVFoundation

final class PlayerController: NSViewController {
    @IBOutlet weak var songTitleLabel: NSTextField!
    
    var asset: AVURLAsset? = nil
    var item: AVPlayerItem? = nil
    var player: AVPlayer? = nil
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Global.current.dataFlowController.state.observeOn(MainScheduler.instance).do(onNext: { result in
            if case PlayerAction.loadRadioStationFeed = result.setBy {
                self.update()
            }
        })
        .subscribe()
        .disposed(by: bag)
    }
    
    func update() {
        guard let track = Global.current.dataFlowController.currentState.state.tracks.first else { return }
        songTitleLabel.stringValue = track.title
        
        print(Global.current.dataFlowController.currentState.state.tracks.map { "nid: \($0.nid ?? "") title: \($0.title)" })
        
        let music = getMusicDirectory()
        
        let client = Global.current.dataFlowController.currentState.state.client!
        guard let nid = track.nid else { return }
        client.downloadTrack(id: nid)
            .do(onSuccess: { [weak self] data in try self?.saveAndPlay(data, to: music.appendingPathComponent("\(UUID().uuidString).aac")) })
            .do(onError: { print("error: \($0)") })
            .subscribe()
            .disposed(by: bag)
    }
    
    func saveAndPlay(_ data: Data, to url: URL) throws {
        print(url)
        try data.write(to: url)
        
        asset = AVURLAsset(url: url)
        item = AVPlayerItem(asset: asset!)
        player = AVPlayer(playerItem: item!)
        player?.volume = 1.0
        player?.rate = 1.0
        
//        self.player!.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: DispatchQueue.main) { time in
//            print(self.player?.currentItem?.status)
//            if self.player?.currentItem?.status == .readyToPlay {
//
//            }
//        }
    }
    
    func getMusicDirectory() -> URL {
        let music = FileManager.default.urls(for: .musicDirectory, in: .userDomainMask).first!.appendingPathComponent("test")
        
        guard !FileManager.default.fileExists(atPath: music.path) else { return music }
        try! FileManager.default.createDirectory(at: music, withIntermediateDirectories: false, attributes: nil)
        return music
    }
    
    deinit {
        print("PlayerController deinit")
    }
}
