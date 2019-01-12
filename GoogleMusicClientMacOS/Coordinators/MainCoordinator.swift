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
    let playerController: PlayerController
    let systemController: SystemController
    
    init(windowController: ApplicationWindowController, controller: MainController) {
        self.windowController = windowController
        self.controller = controller
        self.leftMenuController = LeftMenuController.instantiate()
        self.playerController = PlayerController.instantiate()
        self.systemController = SystemController.instantiate()
        
        _ = controller.view
        initLeftMenu()
        initPlayer()
        initSystemController()
    }

    deinit {
        print("MainCoordinator deinit")
    }
}

extension MainCoordinator: ApplicationCoordinator {
    func handle(_ action: RxActionType) -> RxReduceResult<AppState> {
        switch action {
        case UIAction.showLogIn: return logOff()
        case UIAction.showArtists: removeCurrentMainController()
        case UIAction.showAlbums: removeCurrentMainController()
        case UIAction.showRadio: showMainController(RadioListController.instantiate())
        case UIAction.showPlaylists: removeCurrentMainController()
        case UIAction.showQueuePopover(let view): showQueuePopover(for: view)
        default: break
        }
        
        return RxReduceResult.single({ $0 })
    }
}

private extension MainCoordinator {
    func logOff() -> RxReduceResult<AppState> {
        let controller = LogInController.instantiate()
        windowController.replaceContentController(controller)
        let coordinator = LogInCoordinator(windowController: self.windowController)
        
        return RxReduceResult.single({ $0.mutate(\AppState.coordinator, coordinator) })
    }
    
    func initLeftMenu() {
        controller.addChild(leftMenuController)
        controller.leftContainerView.addSubview(leftMenuController.view)
        leftMenuController.view.lt.edges(to: controller.leftContainerView)
    }
    
    func initPlayer() {
        controller.addChild(playerController)
        controller.bottomContainerView.addSubview(playerController.view)
        playerController.view.lt.edges(to: controller.bottomContainerView)
    }
    
    func initSystemController() {
        controller.addChild(systemController)
        controller.topContainerView.addSubview(systemController.view)
        systemController.view.lt.edges(to: controller.topContainerView)
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
    
    private func showQueuePopover(for view: NSView) {
        controller.showQueuePopover(for: view)
    }
}
