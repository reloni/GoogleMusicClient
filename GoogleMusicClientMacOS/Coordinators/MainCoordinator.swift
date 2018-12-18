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

final class MainCoordinator {
    private unowned let windowController: ApplicationWindowController
    let controller: MainController
    
    init(windowController: ApplicationWindowController, controller: MainController) {
        self.windowController = windowController
        self.controller = controller
    }

    deinit {
        print("MainCoordinator deinit")
    }
}

extension MainCoordinator: ApplicationCoordinator {
    func handle(_ action: RxActionType) -> Observable<RxStateMutator<AppState>> {
        switch action {
        case UIAction.logOff:
            return logOff()
        case UIAction.initMainController:
            initLeftMenu()
            break
        default:
            break
        }
        
        return .just({ $0 })
    }
}

private extension MainCoordinator {
    func logOff() -> Observable<RxStateMutator<AppState>> {
        let controller = LogInController.instantiate()
        windowController.replaceContentController(controller)
        return .just({ state in
            var newState = state
            newState.coordinator = LogInCoordinator(windowController: self.windowController)
            return newState
        })
    }
    
    func initLeftMenu() {
        let left = LeftMenuController.instantiate()
        controller.addChild(left)
        controller.leftContainerView.addSubview(left.view)
        left.view.lt.edges(to: controller.leftContainerView)
    }
}
