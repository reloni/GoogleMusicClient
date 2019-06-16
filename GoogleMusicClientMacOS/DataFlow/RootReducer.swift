//
//  RootReducer.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 14/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import RxDataFlow
import RxSwift

func rootReducer(_ action: RxActionType, currentState: AppState) -> RxReduceResult<AppState> {    
    switch action {
    case _ as UIAction: return currentState.coordinator.handle(action, currentState: currentState)
    case _ as SystemAction: return systemReducer(action, currentState: currentState)
    case _ as PlayerAction: return playerReducer(action, currentState: currentState)
    default: fatalError("Unknown action type")
    }
}
