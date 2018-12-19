//
//  PlayerController.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 19/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa

final class PlayerController: NSViewController {
    @IBOutlet weak var songTitleLabel: NSTextField!
    
    deinit {
        print("PlayerController deinit")
    }
}
