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

final class LogInCoordinator: ApplicationCoordinator {
    private unowned let windowController: ApplicationWindowController
    
    init(windowController: ApplicationWindowController) {
        self.windowController = windowController
    }
    
    func handle(_ action: RxActionType) -> RxStateMutator<AppState> {
        switch action {
        case UIAction.showMain:
            let controller = MainController.instantiate()
            windowController.replaceContentController(controller)
            let coordinator = MainCoordinator(windowController: self.windowController, controller: controller)
            return { $0.mutate(\.coordinator, coordinator) }
        default:
            return AppState.noStateMutator
        }   
    }
    
    deinit {
        print("LogInCoordinator deinit")
    }
}
