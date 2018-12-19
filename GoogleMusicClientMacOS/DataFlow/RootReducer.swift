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
    #if DEBUG
    print("Handle action: \(action.self)")
    #endif
    
    switch action {
    case _ as UIAction: return RxReduceResult.single(currentState.coordinator.handle(action))
    case _ as SystemAction: return systemReducer(action, currentState: currentState)
    case _ as PlayerAction: return playerReducer(action, currentState: currentState)
    default: fatalError("Unknown action type")
    }
}
