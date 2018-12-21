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
            if case PlayerAction.loadRadioStation = result.setBy {
                self.update()
            }
        })
        .subscribe()
        .disposed(by: bag)
    }
    
    func update() {
        guard let track = Global.current.dataFlowController.currentState.state.tracks.first else { return }
        songTitleLabel.stringValue = track.title
    }
    
    deinit {
        print("PlayerController deinit")
    }
}