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
    let errorController: ErrorController
    
    init(windowController: ApplicationWindowController, controller: MainController) {
        self.windowController = windowController
        self.controller = controller
        self.leftMenuController = LeftMenuController.instantiate()
        self.playerController = PlayerController.instantiate()
        self.systemController = SystemController.instantiate()
        self.errorController = ErrorController.instantiate()
        
        _ = controller.view
        initLeftMenu()
        initPlayer()
        initSystemController()
        initErrorController()
    }

    deinit {
        print("MainCoordinator deinit")
    }
}

extension MainCoordinator: ApplicationCoordinator {
    func handle(_ action: RxActionType) -> RxReduceResult<AppState> {
        switch action {
        case UIAction.showLogIn: return logOff()
        case UIAction.showRadio: showMainController(RadioListController())
        case UIAction.showFavorites: showMainController(FavoritesController())
        case UIAction.showQueuePopover(let view): showQueuePopover(for: view)
        case UIAction.showErrorController(let e): showError(e)
        case UIAction.hideErrorController: hideError()
        default: break
        }
        
        return RxReduceResult.single(id)
    }
}

private extension MainCoordinator {
    func showError(_ error: Error) {
        errorController.textLabel.cell?.title = error.localizedDescription
        controller.toggleErrorController(isVisible: true)
    }
    
    func hideError() {
        controller.toggleErrorController(isVisible: false)
    }
    
    func logOff() -> RxReduceResult<AppState> {
        let controller = LogInController.instantiate()
        windowController.replaceContentController(controller)
        let coordinator = LogInCoordinator(windowController: self.windowController)
        
        return RxReduceResult.single({ $0.mutate(\AppState.coordinator, coordinator) })
    }
    
    func initErrorController() {
        controller.addChild(errorController)
        controller.errorContainerView.addSubview(errorController.view)
        errorController.view.lt.edges(to: controller.errorContainerView)
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
