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
import Cocoa

struct CompositeActions {
    static let logOff = RxCompositeAction(SystemAction.clearKeychainToken, UIAction.showLogIn)
    static func logIn(token: GMusicToken) -> RxCompositeAction {
        return RxCompositeAction(SystemAction.saveKeychainToken(token),
                                 SystemAction.initializeMusicClient,
                                 UIAction.showMain)
    }
}

enum UIAction : RxActionType {
    var scheduler: ImmediateSchedulerType? { return MainScheduler.instance }
    case startup(ApplicationWindowController)
   
    case showMain
    case showLogIn
    
    case showRadio
    case showArtists
    case showAlbums
    case showPlaylists
    
    case showQueuePopover(NSView)
}

enum SystemAction: RxActionType {
    case saveKeychainToken(GMusicToken)
    case initializeMusicClient
    case clearKeychainToken
}

enum PlayerAction: RxActionType {
    case loadRadioStations
    case loadRadioStationFeed(GMusicRadioStation)
}
