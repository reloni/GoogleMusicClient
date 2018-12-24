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

final class PlayerController: NSViewController {
    @IBOutlet weak var songTitleLabel: NSTextField!
    
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
        
//        let client = Global.current.dataFlowController.currentState.state.client!
//        guard let nid = track.nid else { return }
//        client.downloadTrack(id: nid)
//            .do(onSuccess: { print("data len: \($0.count)") })
//            .do(onError: { print("error: \($0)") })
//            .subscribe()
//            .disposed(by: bag)
    }
    
    deinit {
        print("PlayerController deinit")
    }
}
