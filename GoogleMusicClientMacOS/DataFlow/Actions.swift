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
    
    static func play(tracks: [GMusicTrack], startIndex: Int) -> RxCompositeAction {
        return RxCompositeAction(UIAction.showProgressIndicator,
                                 PlayerAction.setQueueSource(.list(OrderedSet(elements: tracks))),
                                 PlayerAction.initializeQueueFromSource,
                                 PlayerAction.playAtIndex(startIndex),
                                 UIAction.hideProgressIndicator,
                                 fallbackAction: UIAction.hideProgressIndicator)
    }
    
    static func playShuffled(tracks: [GMusicTrack], startIndex: Int) -> RxCompositeAction {
        return RxCompositeAction(UIAction.showProgressIndicator,
                                 PlayerAction.setQueueSource(.list(OrderedSet(elements: tracks))),
                                 PlayerAction.initializeQueueFromSource,
                                 PlayerAction.shuffleQueue(moveToFirst: startIndex),
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
    case showFavorites
//    case showArtists
//    case showAlbums
//    case showPlaylists
    
    case showProgressIndicator
    case hideProgressIndicator
    
    case showQueuePopover(NSView)
    case showAlert(AlertConfiguration)
    
    case showErrorController(Error)
    case hideErrorController
}

enum SystemAction: RxActionType, Equatable {    
    case saveKeychainToken(GMusicToken)
    case initializeMusicClient
    case initializePlayer
    case creanup
    case toggleQueueRepeat
}

enum PlayerAction: RxActionType, Equatable {
    case setQueueSource(QueueSource)
    case loadRadioStations
    case loadFavorites
    case initializeQueueFromSource
    case pause
    case resume
    case playPrevious
    case playNext
    case toggle
    case playAtIndex(Int)
    case shuffleQueue(moveToFirst: Int?)
    case toggleShuffle
}
