//
//  Actions.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 14/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import RxDataFlow
import RxSwift
import RxGoogleMusic

extension RxActionType {
    var isSerial: Bool { return true }
    var scheduler: ImmediateSchedulerType? { return MainScheduler.instance }
}

enum UIAction : RxActionType {
    case startup(ApplicationWindowController)
    case showMain
    case logOff
}

enum SystemAction: RxActionType {
    case saveKeychainToken(GMusicToken)
    case clearKeychainToken
}
