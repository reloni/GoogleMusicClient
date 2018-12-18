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
    let leftMenuController: LeftMenuController
    
    init(windowController: ApplicationWindowController, controller: MainController) {
        self.windowController = windowController
        self.controller = controller
        self.leftMenuController = LeftMenuController.instantiate()
    }

    deinit {
        print("MainCoordinator deinit")
    }
}

extension MainCoordinator: ApplicationCoordinator {
    func handle(_ action: RxActionType) -> Observable<RxStateMutator<AppState>> {
        switch action {
        case UIAction.showLogIn:
            return logOff()
        case UIAction.initMainController:
            initLeftMenu()
            break
        case UIAction.showArtists:
//            leftMenuController.tableView.selectRowIndexes(IndexSet([]), byExtendingSelection: false)
            break
        case UIAction.showRadio:
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
        controller.addChild(leftMenuController)
        controller.leftContainerView.addSubview(leftMenuController.view)
        leftMenuController.view.lt.edges(to: controller.leftContainerView)
    }
}
