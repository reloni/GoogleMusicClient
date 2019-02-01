//
//  ThreeLabelsCollectionViewItem.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 01/02/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Cocoa

class ThreeLabelsCollectionViewItem: NSCollectionViewItem {
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
