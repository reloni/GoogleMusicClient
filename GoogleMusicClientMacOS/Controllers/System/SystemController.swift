//
//  SystemController.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 12/01/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Cocoa
import RxDataFlow
import RxSwift

final class SystemController: NSViewController, ViewWithBottomBorder {
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBottomBorder(to: view)
    }
    
    func toggleProgressIndicator(_ isActive: Bool) {
        if isActive {
            progressIndicator.startAnimation(self)
        } else {
            progressIndicator.stopAnimation(self)
        }
    }
}
