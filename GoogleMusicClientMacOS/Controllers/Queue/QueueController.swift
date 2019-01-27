//
//  QueueController.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 28/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa
import RxGoogleMusic
import RxSwift

final class QueueController: NSViewController {
    @IBOutlet weak var tableView: ApplicationTableView!
    
    let bag = DisposeBag()
    
    var player: Player<GMusicTrack>? {
        return Current.currentState.state.player
    }
    
    var queue: [GMusicTrack] {
        return Current.currentState.state.queue.items
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = NSColor.clear
        tableView.allowsColumnSelection = false
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.didClickRow = { index in
            Current.dispatch(PlayerAction.playAtIndex(index))
        }

        Current.currentTrack
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in self?.updateTableView(selectedIndex: $0?.index) })
            .disposed(by: bag)
        
        Current.state
            .filter { ($0.setBy as? PlayerAction) == PlayerAction.initializeQueueFromSource }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak tableView] _ in tableView?.scrollToBeginningOfDocument(nil); tableView?.reloadData() })
            .disposed(by: bag)
        
    }
    
    func updateTableView(selectedIndex: Int?) {
        guard let index = selectedIndex else {
            tableView.selectRowIndexes(IndexSet([]), byExtendingSelection: false)
            return
        }
        
        tableView.selectRowIndexes(IndexSet([index]), byExtendingSelection: false)
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
    
    func cell(in tableView: NSTableView, for column: NSTableColumn?) -> NSTableCellView? {
        if column == tableView.tableColumns[0] {
            return tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Title"), owner: self) as? NSTableCellView
        } else if column == tableView.tableColumns[1] {
            return tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Album"), owner: self) as? NSTableCellView
        } else if column == tableView.tableColumns[2] {
            return tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Artist"), owner: self) as? NSTableCellView
        } else if column == tableView.tableColumns[3] {
            return tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Duration"), owner: self) as? NSTableCellView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return HighlightOnHoverTableRowView()
    }
}
