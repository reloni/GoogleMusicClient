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

struct AlertConfiguration {
    let messageText: String
    let informativeText: String
    let alertStyle: NSAlert.Style
    let buttonTitles: [String]
    let completion: (NSApplication.ModalResponse) -> Void
}

protocol ApplicationCoordinator {
    func handle(_ action: RxActionType, currentState: AppState) -> RxReduceResult<AppState>
}

extension ApplicationCoordinator {
    func showAlert(_ configuration: AlertConfiguration) {
        let alert = NSAlert()
        alert.messageText = configuration.messageText
        alert.informativeText = configuration.informativeText
        alert.alertStyle = configuration.alertStyle
        configuration.buttonTitles.forEach {
            alert.addButton(withTitle: $0)
        }
        
        configuration.completion(alert.runModal())
    }
}

final class StartupCoordinator: ApplicationCoordinator {
    func handle(_ action: RxActionType, currentState: AppState) -> RxReduceResult<AppState> {
        switch action {
        case UIAction.startup(let windowController):
            return startup(in: windowController, currentState: currentState)
        default:
            break
        }
        return RxReduceResult.empty
    }
    
    func startup(in windowController: ApplicationWindowController, currentState: AppState) -> RxReduceResult<AppState> {

        let controller = currentState.hasGmusicToken ? MainController.instantiate() : LogInController.instantiate()
        
        let newCoordinator: ApplicationCoordinator = currentState.hasGmusicToken
                ? MainCoordinator(windowController: windowController, controller: controller as! MainController)
                : LogInCoordinator(windowController: windowController)
        
        windowController.replaceContentController(controller)

        return RxReduceResult.single({ $0.mutate(\.coordinator, newCoordinator) })
    }
    
    deinit {
        print("StartupCoordinator deinit")
    }
}
