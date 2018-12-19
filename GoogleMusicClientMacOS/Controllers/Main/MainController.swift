//
//  MainController.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 13/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa
import RxDataFlow
import RxSwift
import RxCocoa
import RxGoogleMusic

final class MainController: NSViewController {
    @IBOutlet weak var leftContainerView: NSView!
    @IBOutlet weak var mainContainerView: NSView!
    @IBOutlet weak var bottomContainerView: NSView!
    
    deinit {
        print("MainController deinit")
    }
}
