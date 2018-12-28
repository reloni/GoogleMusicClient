//
//  MainWindowController.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 13/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa
import RxDataFlow
import RxSwift

final class MainWindowController: NSWindowController, ApplicationController {
    let bag = DisposeBag()
    override func windowDidLoad() {
        super.windowDidLoad()
        
        Global.current.dataFlowController.errors.subscribe(onNext: { error in
            print("ERROR: \(error.error) Action: \(error.action)")
        }).disposed(by: bag)
        
        Global.current.dataFlowController.dispatch(CompositeActions.beforeStartup)
        Global.current.dataFlowController.dispatch(UIAction.startup(self))
    }
    
    deinit {
        print("MainWindowController deinit")
    }
}
