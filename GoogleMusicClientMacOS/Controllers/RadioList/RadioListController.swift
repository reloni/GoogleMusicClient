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
        return Global.current.dataFlowController.currentState.state.client!
    }
    
    let bag = DisposeBag()
    
    var stations: [GMusicRadioStation] {
        return Global.current.dataFlowController.currentState.state.radioStations
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = NSColor.clear
        tableView.allowsColumnSelection = false
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        
        tableView.delegate = self
        tableView.dataSource = self
        
        Global.current.dataFlowController.state.filter { state in
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
        Global.current.dataFlowController.dispatch(action)
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
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard 0..<stations.count ~= tableView.selectedRow else { return }
        let station = stations[tableView.selectedRow]
        Global.current.dataFlowController.dispatch(CompositeActions.play(station: station))
    }
}
