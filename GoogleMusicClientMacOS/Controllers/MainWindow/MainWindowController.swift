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
        
        restoreWindow()
        
        Global.current.dataFlowController.errors.subscribe(onNext: { error in
            print("ERROR: \(error.error) Action: \(error.action)")
        }).disposed(by: bag)

        Global.current.dataFlowController.dispatch(CompositeActions.beforeStartup)
        Global.current.dataFlowController.dispatch(UIAction.startup(self))
    }
    
    func restoreWindow() {
        guard let frame = UserDefaults.standard.mainWindowFrame else { return }
        switch frame {
        case .fullScreen: window?.toggleFullScreen(nil)
        case .rect(let rect): window?.setFrame(rect, display: true, animate: true)
        }
    }
    
    deinit {
        print("MainWindowController deinit")
    }
}

extension MainWindowController: NSWindowDelegate {
    func windowDidEnterFullScreen(_ notification: Notification) {
        UserDefaults.standard.mainWindowFrame = .fullScreen
    }
    
    func windowDidEndLiveResize(_ notification: Notification) {
        UserDefaults.standard.mainWindowFrame = WindowSize.rect(window!.frame)
    }
}
