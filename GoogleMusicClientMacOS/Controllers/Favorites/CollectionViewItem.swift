//
//  CollectionViewItem.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 30/01/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Cocoa

class CollectionViewItem: NSCollectionViewItem {
    @IBOutlet weak var label: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
