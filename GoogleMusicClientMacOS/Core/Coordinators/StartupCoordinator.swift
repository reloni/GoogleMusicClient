//
//  StartupCoordinator.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 13/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa
import RxDataFlow
import RxSwift

protocol ApplicationCoordinator {
    func handle(_ action: RxActionType) -> Observable<RxStateMutator<AppState>>
}

final class StartupCoordinator: ApplicationCoordinator {
    func handle(_ action: RxActionType) -> Observable<RxStateMutator<AppState>> {
        switch action {
        case UIAction.startup(let windowController):
            return startup(in: windowController)
        default:
            break
        }
        return .just({ $0 })
    }
    
    func startup(in windowController: ApplicationWindowController) -> Observable<RxStateMutator<AppState>> {
        let newCoordinator: ApplicationCoordinator =
            Global.current.hasGMusicToken ? MainCoordinator(windowController: windowController) : LogInCoordinator(windowController: windowController)
        
        let controller = Global.current.hasGMusicToken ? MainController.instantiate() : LogInController.instantiate()
        
        windowController.replaceContentController(controller)

        return .just({ state in
            var newState = state
            newState.coordinator = newCoordinator
            return newState
        })
    }
    
    deinit {
        print("StartupCoordinator deinit")
    }
}
