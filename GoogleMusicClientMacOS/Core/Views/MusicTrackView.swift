//
//  ThreeLabelsView.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 01/02/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Cocoa

final class MusicTrackView: NSView, ViewWithBottomBorder {
    let title = ScrollableTextView()
    let album = ScrollableTextView()//VerticallyCenteredTextField()
    let artist = ScrollableTextView()
    let duration = ScrollableTextView()
    
    private lazy var textFields: [ScrollableTextView] = {
       return [title, album, artist, duration]
    }()
    
    var labelsColor = NSColor.textColor {
        didSet {
            textFields.forEach { $0.textColor = labelsColor
            }
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        addSubview(title)
        addSubview(album)
        addSubview(artist)
        addSubview(duration)
        
        setupConstraints()
        
        addBottomBorder(to: self)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        title.lt.top.equal(to: lt.top)
        title.lt.leading.equal(to: lt.leading, constant: 10)
        title.lt.bottom.equal(to: lt.bottom)
        title.lt.trailing.equal(to: artist.lt.leading, constant: -10)
        
        artist.lt.top.equal(to: title.lt.top)
        artist.lt.bottom.equal(to: title.lt.bottom)
        artist.lt.trailing.equal(to: album.lt.leading, constant: -10)
        
        album.lt.top.equal(to: title.lt.top)
        album.lt.bottom.equal(to: title.lt.bottom)
        album.lt.trailing.equal(to: duration.lt.leading, constant: -10)
        
        duration.lt.top.equal(to: title.lt.top)
        duration.lt.bottom.equal(to: title.lt.bottom)
        duration.lt.trailing.equal(to: lt.trailing, constant: -10)
        
        title.lt.width.equal(to: lt.width, constant: 0, multiplier: 0.5)
        artist.lt.width.equal(to: album.lt.width)
        duration.lt.width.equal(to: 60)
    }
}
