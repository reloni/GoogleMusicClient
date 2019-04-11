//
//  ApplicationCollectionView.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 11/04/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Cocoa

final class ApplicationCollectionView: NSCollectionView {
    var didClickItem: ((IndexPath) -> Void)?
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        guard let ip = indexPathForItem(at: convert(event.locationInWindow, from: nil)) else { return }
        
        didClickItem?(ip)
    }
}
