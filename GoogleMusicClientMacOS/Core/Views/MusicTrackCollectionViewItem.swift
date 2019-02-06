//
//  ThreeLabelsCollectionViewItem.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 01/02/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Cocoa

final class TextFieldCollectionViewItem: NSCollectionViewItem {
    let itemTextField = VerticallyCenteredTextField()
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            (view as? SelectableNSView)?.isSelected = isSelected
        }
    }
    
    override func loadView() {
        view = SelectableNSView()
        view.addSubview(itemTextField)
        itemTextField.lt.top.equal(to: view.lt.top)
        itemTextField.lt.leading.equal(to: view.lt.leading, constant: 10)
        itemTextField.lt.bottom.equal(to: view.lt.bottom)
        itemTextField.lt.trailing.equal(to: view.lt.trailing, constant: -10)
    }
}

final class MusicTrackCollectionViewItem: NSCollectionViewItem {
    let musicTrackView = MusicTrackView()
    
    override var isSelected: Bool {
        didSet {
            (view as? SelectableNSView)?.isSelected = isSelected
            if isSelected {
                musicTrackView.labelsColor = NSColor.selectedItemTextColor
            } else {
                musicTrackView.labelsColor = NSColor.textColor
            }
        }
    }
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = SelectableNSView()
        view.addSubview(musicTrackView)
        musicTrackView.lt.edges(to: view)
    }
}
