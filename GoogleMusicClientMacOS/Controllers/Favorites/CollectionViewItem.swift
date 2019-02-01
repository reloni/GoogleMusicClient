//
//  CollectionViewItem.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 30/01/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Cocoa

final class VerticallyCenteredTextField: NSView {
    let textField = NSTextField()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        addSubview(textField)
        textField.lt.leading(to: lt.leading)
        textField.lt.trailing(to: lt.trailing)
        textField.lt.centerY(to: lt.centerY)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CollectionViewItem: NSCollectionViewItem {
    let trackTitle = VerticallyCenteredTextField().configure {
        $0.textField.isEditable = false
        $0.textField.isBezeled = false
        $0.textField.drawsBackground = false
        $0.textField.usesSingleLineMode = false
        $0.textField.font = NSFont.systemFont(ofSize: 13, weight: NSFont.Weight.medium)
    }
    
    let album = VerticallyCenteredTextField().configure {
        $0.textField.isEditable = false
        $0.textField.isBezeled = false
        $0.textField.drawsBackground = false
        $0.textField.usesSingleLineMode = false
        $0.textField.font = NSFont.systemFont(ofSize: 13, weight: NSFont.Weight.medium)
    }
    
    let artist = VerticallyCenteredTextField().configure {
        $0.textField.isEditable = false
        $0.textField.isBezeled = false
        $0.textField.drawsBackground = false
        $0.textField.usesSingleLineMode = false
        $0.textField.font = NSFont.systemFont(ofSize: 13, weight: NSFont.Weight.medium)
    }
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = HighlightOnHoverView()
        view.addSubview(trackTitle)
        view.addSubview(album)
        view.addSubview(artist)
        setupConstraints()
    }

    func setupConstraints() {
        trackTitle.lt.top(to: view.lt.top)
        trackTitle.lt.leading(to: view.lt.leading, constant: 10)
        trackTitle.lt.bottom(to: view.lt.bottom)
        trackTitle.lt.trailing(to: artist.lt.leading, constant: -10)
        
        artist.lt.top(to: trackTitle.lt.top)
        artist.lt.bottom(to: trackTitle.lt.bottom)
        artist.lt.trailing(to: album.lt.leading, constant: -10)
        
        album.lt.top(to: trackTitle.lt.top)
        album.lt.bottom(to: trackTitle.lt.bottom)
        album.lt.trailing(to: view.lt.trailing, constant: -10)
        
        trackTitle.lt.width(to: view.lt.width, constant: 0, multiplier: 0.5)
        artist.lt.width(to: album.lt.width)
    }
}
