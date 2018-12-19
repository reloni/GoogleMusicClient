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
    func handle(_ action: RxActionType) -> RxReduceResult<AppState>
}

final class StartupCoordinator: ApplicationCoordinator {
    func handle(_ action: RxActionType) -> RxReduceResult<AppState> {
        switch action {
        case UIAction.startup(let windowController):
            return startup(in: windowController)
        default:
            break
        }
        return RxReduceResult.empty
    }
    
    func startup(in windowController: ApplicationWindowController) -> RxReduceResult<AppState> {
        let hasGmusicToken = Global.current.dataFlowController.currentState.state.hasGmusicToken
        
        let controller = hasGmusicToken ? MainController.instantiate() : LogInController.instantiate()
        
        let newCoordinator: ApplicationCoordinator = hasGmusicToken
                ? MainCoordinator(windowController: windowController, controller: controller as! MainController)
                : LogInCoordinator(windowController: windowController)
        
        windowController.replaceContentController(controller)

        return RxReduceResult.single({ $0.mutate(\.coordinator, newCoordinator) })
    }
    
    deinit {
        print("StartupCoordinator deinit")
    }
}
