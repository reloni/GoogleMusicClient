//
//  RadioListController.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 18/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa
import RxGoogleMusic
import RxSwift
import RxDataFlow

final class RadioListController: NSViewController {
    @IBOutlet weak var tableView: ApplicationTableView!
    
    var client: GMusicClient {
        return Current.currentState.state.client!
    }
    
    let bag = DisposeBag()
    
    var stations: [GMusicRadioStation] {
        return Current.currentState.state.radioStations
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = NSColor.clear
        tableView.allowsColumnSelection = false
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.didClickRow = { [weak self] index in
            guard let self = self else { return }
            guard 0..<self.stations.count ~= self.tableView.selectedRow else { return }
            let station = self.stations[self.tableView.selectedRow]
            Current.dispatch(CompositeActions.play(station: station))
        }
        
        Current.state.filter { state in
            switch state.setBy {
            case PlayerAction.loadRadioStations: return true
            default: return false
            }
        }.observeOn(MainScheduler.instance)
            .do(onNext: { [weak self] _ in self?.tableView.reloadData() })
            .subscribe()
            .disposed(by: bag)
        
        
        let action = RxCompositeAction(UIAction.showProgressIndicator,
                                 PlayerAction.loadRadioStations,
                                 UIAction.hideProgressIndicator,
                                 fallbackAction: UIAction.hideProgressIndicator)
        Current.dispatch(action)
    }
    
    deinit {
        print("RadioListController deinit")
    }
}

extension RadioListController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return stations.count
    }
}

extension RadioListController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Cell"), owner: self) as! NSTableCellView
        cell.textField?.stringValue = stations[row].name
        return cell
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return HighlightOnHoverTableRowView()
    }
}
