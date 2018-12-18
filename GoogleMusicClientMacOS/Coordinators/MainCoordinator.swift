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
    weak var mainController: NSViewController? = nil
    
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
        case UIAction.showLogIn: return logOff()
        case UIAction.initMainController: initLeftMenu()
        case UIAction.showArtists: removeCurrentMainController()
        case UIAction.showAlbums: removeCurrentMainController()
        case UIAction.showRadio: showMainController(RadioListController.instantiate())
        case UIAction.showPlaylists: removeCurrentMainController()
        default: break
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
    
    private func removeCurrentMainController() {
        mainController?.view.removeFromSuperview()
        mainController?.removeFromParent()
    }
    
    private func showMainController(_ newController: NSViewController) {
        removeCurrentMainController()
        
        controller.addChild(newController)
        controller.mainContainerView.addSubview(newController.view)
        newController.view.lt.edges(to: controller.mainContainerView)
        
        mainController = newController
    }
}
