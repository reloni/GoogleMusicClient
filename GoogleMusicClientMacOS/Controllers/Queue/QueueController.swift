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
    
    deinit {
        print("QueueController deinit")
    }
}

extension QueueController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return queue.count
    }
}

extension QueueController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let c = cell(in: tableView, for: tableColumn)
        switch c?.identifier?.rawValue {
        case "Title": c?.textField?.stringValue = queue[row].title
        case "Album": c?.textField?.stringValue = queue[row].album
        case "Artist": c?.textField?.stringValue = queue[row].artist
        case "Duration": c?.textField?.stringValue = queue[row].duration.timeString ?? "--:--"
        default: break
        }
        return c
    }
    
//    func tableViewSelectionDidChange(_ notification: Notification) {
//        guard 0..<stations.count ~= tableView.selectedRow else { return }
//        let station = stations[tableView.selectedRow]
//        Global.current.dataFlowController.dispatch(PlayerAction.loadRadioStationFeed(station))
//    }
    
    func cell(in tableView: NSTableView, for column: NSTableColumn?) -> NSTableCellView? {
        if column == tableView.tableColumns[0] {
            return tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Title"), owner: nil) as? NSTableCellView
        } else if column == tableView.tableColumns[1] {
            return tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Album"), owner: nil) as? NSTableCellView
        } else if column == tableView.tableColumns[2] {
            return tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Artist"), owner: nil) as? NSTableCellView
        } else if column == tableView.tableColumns[3] {
            return tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Duration"), owner: nil) as? NSTableCellView
        } else {
            return nil
        }
    }
}
