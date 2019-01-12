//
//  SystemController.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 12/01/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Cocoa
import RxDataFlow
import RxSwift

final class SystemController: NSViewController {
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Global.current.dataFlowController.state
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] state in
                switch state.setBy {
                case UIAction.showProgressIndicator: self?.toggleProgressIndicator(true)
                case UIAction.hideProgressIndicator: self?.toggleProgressIndicator(false)
                default: break
                }
            })
            .disposed(by: bag)
    }
    
    func toggleProgressIndicator(_ isActive: Bool) {
        if isActive {
            progressIndicator.startAnimation(self)
        } else {
            progressIndicator.stopAnimation(self)
        }
    }
}
