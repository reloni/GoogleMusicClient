//
//  ThreeLabelsView.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 01/02/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Cocoa

final class MusicTrackView: NSView {
    let title = VerticallyCenteredTextField()
    let album = VerticallyCenteredTextField()
    let artist = VerticallyCenteredTextField()
    let duration = VerticallyCenteredTextField()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        addSubview(title)
        addSubview(album)
        addSubview(artist)
        addSubview(duration)
        setupConstraints()
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        title.lt.top(to: lt.top)
        title.lt.leading(to: lt.leading, constant: 10)
        title.lt.bottom(to: lt.bottom)
        title.lt.trailing(to: artist.lt.leading, constant: -10)
        
        artist.lt.top(to: title.lt.top)
        artist.lt.bottom(to: title.lt.bottom)
        artist.lt.trailing(to: album.lt.leading, constant: -10)
        
        album.lt.top(to: title.lt.top)
        album.lt.bottom(to: title.lt.bottom)
        album.lt.trailing(to: duration.lt.leading, constant: -10)
        
        duration.lt.top(to: title.lt.top)
        duration.lt.bottom(to: title.lt.bottom)
        duration.lt.trailing(to: lt.trailing, constant: -10)
        
        title.lt.width(to: lt.width, constant: 0, multiplier: 0.5)
        artist.lt.width(to: album.lt.width)
        duration.lt.width.equal(to: 60)
    }
}
