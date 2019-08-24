//
//  AppDelegate.swift
//  GoogleMusicClient
//
//  Created by Anton Efimenko on 13/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa
import RxDataFlow
import RxGoogleMusic
import os.log

let Current = RxDataFlowController(reducer: rootReducer, initialState: initialState())

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(appSleep), name: NSWorkspace.willSleepNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(appWake), name: NSWorkspace.didWakeNotification, object: nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc func appWake() {
        os_log(.default, log: .general, "App didWake")
    }
    
    @objc func appSleep() {
        os_log(.default, log: .general, "App willSleep")
    }
}

class Application: NSApplication {
    override func sendEvent(_ event: NSEvent) {
        if (event.type == .systemDefined && event.subtype.rawValue == 8) {
            let keyCode = ((event.data1 & 0xFFFF0000) >> 16)
            let keyFlags = (event.data1 & 0x0000FFFF)
            // Get the key state. 0xA is KeyDown, OxB is KeyUp
            let keyState = (((keyFlags & 0xFF00) >> 8)) == 0xA
            let keyRepeat = (keyFlags & 0x1)
            mediaKeyEvent(key: Int32(keyCode), state: keyState, keyRepeat: keyRepeat != 0)
        }

        super.sendEvent(event)
    }
    
    func mediaKeyEvent(key: Int32, state: Bool, keyRepeat: Bool) {
        // Only send events on KeyDown and non repeat
        guard state && !keyRepeat else { return }
        switch(key) {
        case NX_KEYTYPE_PLAY:
            Current.dispatch(PlayerAction.toggle)
        case NX_KEYTYPE_FAST:
            Current.dispatch(PlayerAction.playNext)
        case NX_KEYTYPE_REWIND:
            Current.dispatch(PlayerAction.playPrevious)
        default:
            break
        }
    }
}
