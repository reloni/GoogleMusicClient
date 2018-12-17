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
import RxCocoa
import RxGoogleMusic

final class LeftMenuController: NSViewController {
    @IBOutlet weak var tableView: ApplicationTableView!
    
    let rows = ["First", "Second", "Third"]
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        tableView.delegate = self
        tableView.dataSource = self
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
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Cell"), owner: nil) as! NSTableCellView
        cell.textField?.stringValue = rows[row]
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {

    }
}
