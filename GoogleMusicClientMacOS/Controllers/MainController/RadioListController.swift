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

final class RadioListController: NSViewController {
    @IBOutlet weak var tableView: ApplicationTableView!
    
    var client: GMusicClient {
        return GMusicClient(token: Global.current.gMusicToken!)
    }
    
    let bag = DisposeBag()
    
    
    var stations: [GMusicRadioStation] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = NSColor.clear
        tableView.allowsColumnSelection = false
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        
        tableView.delegate = self
        tableView.dataSource = self
        
        client
            .radioStations()
            .map { $0.items }
            .asDriver(onErrorJustReturn: stations)
            .do(onNext: { [weak self] in self?.stations = $0 })
            .drive()
            .disposed(by: bag)
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
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Cell"), owner: nil) as! NSTableCellView
        cell.textField?.stringValue = stations[row].name
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard 0..<stations.count ~= tableView.selectedRow else { return }
        let station = stations[tableView.selectedRow]
        client.radioStationFeed(for: station)
            .do(onNext: { result in print(result.items.first!.tracks.map { "\($0.id?.uuidString ?? "") | \($0.title)" }) })
            .subscribe()
            .disposed(by: bag)
    }
}
