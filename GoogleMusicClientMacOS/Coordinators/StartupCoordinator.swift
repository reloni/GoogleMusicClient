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
        let controller = Global.current.authenticated ? MainController.instantiate() : LogInController.instantiate()
        
        let newCoordinator: ApplicationCoordinator =
            Global.current.authenticated
                ? MainCoordinator(windowController: windowController, controller: controller as! MainController)
                : LogInCoordinator(windowController: windowController)
        
        windowController.replaceContentController(controller)

        return .just({ $0.mutate(\.coordinator, newCoordinator) })
    }
    
    deinit {
        print("StartupCoordinator deinit")
    }
}
