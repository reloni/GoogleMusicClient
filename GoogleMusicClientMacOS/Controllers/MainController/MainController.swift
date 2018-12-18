//
//  MainController.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 13/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa
import RxDataFlow
import RxSwift
import RxCocoa
import RxGoogleMusic

final class MainController: NSViewController {
    var client: GMusicClient {
        return GMusicClient(token: Global.current.gMusicToken!)
    }
    
    let bag = DisposeBag()
    
    @IBOutlet weak var tableView: ApplicationTableView!
    @IBOutlet weak var leftContainerView: NSView!
    @IBOutlet weak var mainContainerView: NSView!
    
    var stations: [GMusicRadioStation] = [] {
        didSet {
//            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Global.current.dataFlowController.dispatch(UIAction.initMainController)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()

//        tableView.delegate = self
//        tableView.dataSource = self
        
//        client
//            .radioStations()
//            .map { $0.items }
//            .asDriver(onErrorJustReturn: stations)
//            .do(onNext: { [weak self] in self?.stations = $0 })
//            .drive()
//            .disposed(by: bag)
    }
    
    deinit {
        print("MainController deinit")
    }
}

extension MainController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return stations.count
    }
}

extension MainController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Cell"), owner: nil) as! NSTableCellView
        cell.textField?.stringValue = stations[row].name
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
//        let station = stations[tableView.selectedRow]
//        client.radioStationFeed(for: station)
//            .do(onNext: { result in print(result.items.first!.tracks.map { "\($0.id?.uuidString ?? "") | \($0.title)" }) })
//            .subscribe()
//            .disposed(by: bag)
    }
}
