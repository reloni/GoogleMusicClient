//
//  MainController.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 13/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa
import RxDataFlow
import RxGoogleMusic

final class MainController: NSViewController {
    var client: GMusicClient {
        return GMusicClient(token: Global.current.gMusicToken!)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        _ = client.radioStations().subscribe(onNext: { print($0.items.count) })
    }
    
    @IBAction func logOff(_ sender: Any) {
        Global.current.dataFlowController.dispatch(RxCompositeAction(SystemAction.clearKeychainToken,
                                                                     UIAction.logOff))
    }
    
    deinit {
        print("MainController deinit")
    }
}
