//
//  ThreeLabelsCollectionViewItem.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 01/02/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Cocoa

final class MusicTrackCollectionViewItem: NSCollectionViewItem, ViewWithBottomBorder {
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
        
        addBottomBorder(to: view)
    }
}
