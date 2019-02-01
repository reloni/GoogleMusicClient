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

final class ThreeLabelsView: NSView {
    let first = VerticallyCenteredTextField().configure {
        $0.textField.isEditable = false
        $0.textField.isBezeled = false
        $0.textField.drawsBackground = false
        $0.textField.usesSingleLineMode = false
        $0.textField.font = NSFont.systemFont(ofSize: 13, weight: NSFont.Weight.medium)
    }
    
    let second = VerticallyCenteredTextField().configure {
        $0.textField.isEditable = false
        $0.textField.isBezeled = false
        $0.textField.drawsBackground = false
        $0.textField.usesSingleLineMode = false
        $0.textField.font = NSFont.systemFont(ofSize: 13, weight: NSFont.Weight.medium)
    }
    
    let third = VerticallyCenteredTextField().configure {
        $0.textField.isEditable = false
        $0.textField.isBezeled = false
        $0.textField.drawsBackground = false
        $0.textField.usesSingleLineMode = false
        $0.textField.font = NSFont.systemFont(ofSize: 13, weight: NSFont.Weight.medium)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        addSubview(first)
        addSubview(second)
        addSubview(third)
        setupConstraints()
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        first.lt.top(to: lt.top)
        first.lt.leading(to: lt.leading, constant: 10)
        first.lt.bottom(to: lt.bottom)
        first.lt.trailing(to: third.lt.leading, constant: -10)
        
        third.lt.top(to: first.lt.top)
        third.lt.bottom(to: first.lt.bottom)
        third.lt.trailing(to: second.lt.leading, constant: -10)
        
        second.lt.top(to: first.lt.top)
        second.lt.bottom(to: first.lt.bottom)
        second.lt.trailing(to: lt.trailing, constant: -10)
        
        first.lt.width(to: lt.width, constant: 0, multiplier: 0.5)
        third.lt.width(to: second.lt.width)
    }
}

class CollectionViewItem: NSCollectionViewItem {
    let musicTrackView = ThreeLabelsView()
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = HighlightOnHoverView()
        view.addSubview(musicTrackView)
        musicTrackView.lt.edges(to: view)
    }
}
