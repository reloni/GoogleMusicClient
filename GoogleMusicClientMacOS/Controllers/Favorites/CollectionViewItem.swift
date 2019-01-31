//
//  CollectionViewItem.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 30/01/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Cocoa

class CollectionViewItem: NSCollectionViewItem {
    let titleLabel: NSTextField = {
        let tf = NSTextField()
        tf.isEditable = false
        tf.isBezeled = false
        tf.drawsBackground = false
        return tf
    }()
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = NSView()
        view.addSubview(titleLabel)
        setupConstraints()
    }

    func setupConstraints() {
        titleLabel.lt.edges(to: view)
    }
}
