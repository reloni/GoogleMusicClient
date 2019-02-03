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

final class QueueController2: NSViewController {
    let collectionView = NSCollectionView().configure { view in
        view.backgroundColors = [.clear]
        view.allowsMultipleSelection = false
        view.isSelectable = true
        view.collectionViewLayout = NSCollectionViewFlowLayout().configure {
            $0.minimumLineSpacing = 0
            $0.scrollDirection = .vertical
        }
        view.registerItem(forClass: ThreeLabelsCollectionViewItem.self)
        view.registerHeader(forClass: MusicTrackView.self)
    }
    
    lazy var scrollView = NSScrollView().configure { $0.documentView = self.collectionView }
    
    let bag = DisposeBag()
    
    var queue: [GMusicTrack] {
        return Current.currentState.state.queue.items
    }
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = NSView()
        view.addSubview(scrollView)
        scrollView.lt.edges(to: view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        Current.currentTrack
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak collectionView] in collectionView?.selectItem(index: $0?.index) })
            .disposed(by: bag)
        
        Current.state
            .filter { ($0.setBy as? PlayerAction) == PlayerAction.initializeQueueFromSource }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak collectionView] _ in
                collectionView?.scrollToBeginningOfDocument(nil)
                collectionView?.reloadData()
            })
            .disposed(by: bag)
        
    }
    
    override func viewWillLayout() {
        super.viewWillLayout()
        collectionView.collectionViewLayout?.invalidateLayout()
    }
    
    deinit {
        print("QueueController deinit")
    }
}

extension QueueController2: NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return NSSize(width: collectionView.bounds.width, height: 40)
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
        return NSSize(width: collectionView.bounds.width, height: 30)
    }
}

extension QueueController2: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let index = indexPaths.first?.item else { return }
        Current.dispatch(PlayerAction.playAtIndex(index))
    }
}

extension QueueController2: NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return queue.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        if kind == NSCollectionView.elementKindSectionHeader {
            let view: MusicTrackView = collectionView.makeHeader(for: indexPath)
            return view.configure {
                $0.title.textField.stringValue = "Title"
                $0.album.textField.stringValue = "Album"
                $0.artist.textField.stringValue = "Artist"
                $0.duration.textField.stringValue = "Duration"
            }
        }
        
        return NSView()
    }
    
    func collectionView(_ itemForRepresentedObjectAtcollectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item: ThreeLabelsCollectionViewItem = collectionView.makeItem(for: indexPath)
        let track = queue[indexPath.item]
        
        item.musicTrackView.title.textField.stringValue = track.title
        item.musicTrackView.album.textField.stringValue = track.album
        item.musicTrackView.artist.textField.stringValue = track.artist
        item.musicTrackView.duration.textField.stringValue = track.duration.timeString ?? "--:--"
        
        return item
    }
}

