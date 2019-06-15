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
import GoogleMusicClientCore

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
    
    static func repeatFromQueueSource(shuffle: Bool) -> RxCompositeAction {
        let actions: [RxActionType] = [UIAction.showProgressIndicator,
                                       PlayerAction.initializeQueueFromSource,
                                       shuffle ? PlayerAction.shuffleQueue(moveToFirst: nil) : nil,
                                       PlayerAction.playNext,
                                       UIAction.hideProgressIndicator].compactMap(id)
        return RxCompositeAction(actions: actions, fallbackAction: UIAction.hideProgressIndicator)
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
    case showAlbumPreviewPopover(NSView)
}

enum SystemAction: RxActionType, Equatable {    
    case saveKeychainToken(GMusicToken)
    case initializeMusicClient
    case initializePlayer
    case creanup
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
    case toggleQueueRepeat
}
