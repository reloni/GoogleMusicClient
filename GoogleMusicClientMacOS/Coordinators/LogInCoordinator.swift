//
//  LogInCoordinator.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 13/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa
import RxGoogleMusic
import RxSwift
import RxDataFlow
import GoogleMusicClientCore

final class LogInCoordinator: ApplicationCoordinator {
    private unowned let windowController: ApplicationWindowController
    
    init(windowController: ApplicationWindowController) {
        self.windowController = windowController
    }
    
    func handle(_ action: RxActionType) -> RxReduceResult<AppState> {
        switch action {
        case UIAction.showMain:
            let controller = MainController.instantiate()
            windowController.replaceContentController(controller)
            let coordinator = MainCoordinator(windowController: self.windowController, controller: controller)
            return RxReduceResult.single({ $0.mutate(\.coordinator, coordinator) })
        case UIAction.showAlert(let configuration):
            showAlert(configuration)
            return RxReduceResult.single(id)
        default:
            return RxReduceResult.empty
        }   
    }
    
    deinit {
        print("LogInCoordinator deinit")
    }
}
