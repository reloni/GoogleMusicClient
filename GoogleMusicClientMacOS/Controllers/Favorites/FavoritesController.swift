//
//  FavoritesController.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 29/01/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Cocoa
import RxSwift
import RxGoogleMusic
import RxDataFlow

final class FavoritesController: NSViewController {
    @IBOutlet weak var tableView: ApplicationTableView!
    
    let bag = DisposeBag()
    
    var player: Player<GMusicTrack>? {
        return Current.currentState.state.player
    }
    
    var favorites: [GMusicTrack] {
        return Current.currentState.state.favorites
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        Current.state.filter { state in
            switch state.setBy {
            case PlayerAction.loadFavorites: return true
            default: return false
            }
            }.observeOn(MainScheduler.instance)
            .do(onNext: { [weak self] _ in self?.tableView.reloadData() })
            .subscribe()
            .disposed(by: bag)
        
        if favorites.count == 0 {
            let action = RxCompositeAction(UIAction.showProgressIndicator,
                                           PlayerAction.loadFavorites,
                                           UIAction.hideProgressIndicator,
                                           fallbackAction: UIAction.hideProgressIndicator)
            Current.dispatch(action)
        }
    }
    
    deinit {
        print("FavoritesController deinit")
    }
}

extension FavoritesController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return favorites.count
    }
}

extension FavoritesController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let c = cell(in: tableView, for: tableColumn)
        switch c?.identifier?.rawValue {
        case "Title": c?.textField?.stringValue = favorites[row].title
        case "Album": c?.textField?.stringValue = favorites[row].album
        case "Artist": c?.textField?.stringValue = favorites[row].artist
        case "Duration": c?.textField?.stringValue = favorites[row].duration.timeString ?? "--:--"
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
