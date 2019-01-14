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
    static let beforeStartup = RxCompositeAction(SystemAction.initializeMusicClient, SystemAction.initializePlayer)
    
    static let logOff = RxCompositeAction(SystemAction.creanup, UIAction.showLogIn)
    
    static func logIn(token: GMusicToken) -> RxCompositeAction {
        return RxCompositeAction(SystemAction.saveKeychainToken(token),
                                 SystemAction.initializeMusicClient,
                                 SystemAction.initializePlayer,
                                 UIAction.showMain)
    }
    
    static func play(station: GMusicRadioStation) -> RxCompositeAction {
        return RxCompositeAction(UIAction.showProgressIndicator,
                                 PlayerAction.setQueueSource(.radio(station)),
                                 PlayerAction.initializeQueueFromSource,
                                 PlayerAction.playNext,
                                 UIAction.hideProgressIndicator,
                                 fallbackAction: UIAction.hideProgressIndicator)
    }
    
    static func repeatFromQueueSource() -> RxCompositeAction {
        return RxCompositeAction(UIAction.showProgressIndicator,
                                 PlayerAction.initializeQueueFromSource,
                                 PlayerAction.playNext,
                                 UIAction.hideProgressIndicator,
                                 fallbackAction: UIAction.hideProgressIndicator)
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
    
    case showProgressIndicator
    case hideProgressIndicator
    
    case showQueuePopover(NSView)
}

enum SystemAction: RxActionType {    
    case saveKeychainToken(GMusicToken)
    case initializeMusicClient
    case initializePlayer
    case creanup
}

enum PlayerAction: RxActionType {
    case setQueueSource(QueueSource)
    case loadRadioStations
    case initializeQueueFromSource
    case pause
    case resume
    case playPrevious
    case playNext
    case toggle
    case playAtIndex(Int)
}
