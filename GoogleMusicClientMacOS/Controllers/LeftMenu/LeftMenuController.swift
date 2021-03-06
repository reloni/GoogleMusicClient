//
//  LeftMenuController.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 17/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa
import RxDataFlow
import RxSwift
import RxGoogleMusic

final class LeftMenuController: NSViewController {
    @IBOutlet weak var tableView: ApplicationTableView!
    
    let rows: [(String, RxActionType)] = [("Radio", UIAction.showRadio),
                                          ("Favorites", UIAction.showFavorites),
//                                          ("Artists", UIAction.showArtists),
//                                          ("Albums", UIAction.showAlbums),
//                                          ("Playlists", UIAction.showPlaylists),
                                          ("Log off", CompositeActions.logOff)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.selectRowIndexes(IndexSet([0]), byExtendingSelection: false)
    }
    
    deinit {
        print("LeftMenuController deinit")
    }
}

extension LeftMenuController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return rows.count
    }
}

extension LeftMenuController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Cell"), owner: self) as! NSTableCellView
        cell.textField?.stringValue = rows[row].0
        return cell
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return LeftHighlightTableRowView()
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard tableView.selectedRow >= 0 && tableView.selectedRow < rows.count else { return }
        Current.dispatch(rows[tableView.selectedRow].1)
    }
}
