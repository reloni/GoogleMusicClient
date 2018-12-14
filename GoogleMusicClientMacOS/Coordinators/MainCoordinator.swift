//
//  MainCoordinator.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 13/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa
import RxDataFlow
import RxSwift

final class MainCoordinator: ApplicationCoordinator {
    private unowned let windowController: ApplicationWindowController
    
    init(windowController: ApplicationWindowController) {
        self.windowController = windowController
    }
    
    func handle(_ action: RxActionType) -> Observable<RxStateMutator<AppState>> {
        switch action {
        case UIAction.logOff:
            let controller = LogInController.instantiate()
            windowController.replaceContentController(controller)
            return .just({ state in
                var newState = state
                newState.coordinator = LogInCoordinator(windowController: self.windowController)
                return newState
            })
        default:
            return .just({ $0 })
        }
    }
    
    deinit {
        print("MainCoordinator deinit")
    }
}
