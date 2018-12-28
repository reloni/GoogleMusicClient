//
//  QueueController.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 28/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa
import RxGoogleMusic

final class QueueController: NSViewController {
    @IBOutlet weak var tableView: ApplicationTableView!
    
    var queue: [GMusicTrack] {
        return Global.current.dataFlowController.currentState.state.player?.items ?? []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension QueueController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return queue.count
    }
}

extension QueueController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Cell"), owner: nil) as! NSTableCellView
        cell.textField?.stringValue = queue[row].title
        return cell
    }
    
//    func tableViewSelectionDidChange(_ notification: Notification) {
//        guard 0..<stations.count ~= tableView.selectedRow else { return }
//        let station = stations[tableView.selectedRow]
//        Global.current.dataFlowController.dispatch(PlayerAction.loadRadioStationFeed(station))
//    }
}
