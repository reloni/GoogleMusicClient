//
//  RootReducer.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 14/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import RxDataFlow
import RxSwift

func rootReducer(_ action: RxActionType, currentState: AppState) -> Observable<RxStateMutator<AppState>> {
    #if DEBUG
    print("Handle action: \(action.self)")
    #endif
    
    switch action {
    case _ as UIAction: return currentState.coordinator.handle(action)
    case _ as SystemAction: return systemReducer(action, currentState: currentState)
    default: fatalError("Unknown action type")
    }
}
