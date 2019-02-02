//
//  ViewWithTrackingArea.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 27/01/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Cocoa

@objc protocol ViewWithTrackingArea: class {
    var trackingAreaBounds: NSRect { get }
    var trackingAreaOptions: NSTrackingArea.Options { get set }
    var trackingAreas: [NSTrackingArea] { get }
    var postsBoundsChangedNotifications: Bool { get set }
    var postsFrameChangedNotifications: Bool { get set }
    func setupTrackingArea()
    func boundsChanged()
    func refreshTrackingArea()
    func addTrackingArea(_ trackingArea: NSTrackingArea)
    func removeTrackingArea(_ trackingArea: NSTrackingArea)
}

extension NSView: ViewWithTrackingArea {
    var trackingAreaBounds: NSRect { return bounds }
    
    var trackingAreaOptions: NSTrackingArea.Options { get { return [] } set { } }
    
    func setupTrackingArea() {
        postsBoundsChangedNotifications = true
        postsFrameChangedNotifications = true
        NotificationCenter.default.addObserver(self, selector: #selector(boundsChanged), name: NSView.boundsDidChangeNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(boundsChanged), name: NSView.frameDidChangeNotification, object: self)
    }
    
    func refreshTrackingArea() {
        trackingAreas.forEach { removeTrackingArea($0) }
        addTrackingArea(NSTrackingArea(rect: trackingAreaBounds, options: trackingAreaOptions, owner: self, userInfo: nil))
    }
    
    func boundsChanged() {
        refreshTrackingArea()
    }
}
