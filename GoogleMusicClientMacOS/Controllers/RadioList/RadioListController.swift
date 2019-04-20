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
import GoogleMusicClientCore

final class RadioListController: NSViewController {
    let collectionView: ApplicationCollectionView = ApplicationCollectionView()
        |> baseCollectionView()
        |> layout(radioListCollectionViewLayout)
        |> register(item: RadioStationCollectionViewItem.self)
    
    lazy var scrollView = NSScrollView()
        |> mainViewScrollView()
        |> mutate { $0.documentView = self.collectionView }
    
    var client: GMusicClient {
        return Current.currentState.state.client!
    }
    
    let bag = DisposeBag()
    
    var stations: [GMusicRadioStation] {
        return Current.currentState.state.radioStations
    }
    
    override func loadView() {
        view = NSView()
        view.addSubview(scrollView)
        scrollView.lt.edges(to: view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        
        collectionView.didClickItem = { [weak self] ip in
            self?.selectStation(at: ip.item)
        }
        
        Current.state
            .filter(isSetBy(PlayerAction.loadRadioStations))
            .observeOn(MainScheduler.instance)
            .do(onNext: { [weak self] _ in self?.collectionView.reloadSections(IndexSet(integer: 0)) })
            .subscribe()
            .disposed(by: bag)
        
        Current.currentRadio
            .filter { $0 != nil }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak collectionView] in collectionView?.selectItem(index: $0?.index) })
            .disposed(by: bag)
        
        if stations.count == 0 {
            let action = RxCompositeAction(UIAction.showProgressIndicator,
                                           PlayerAction.loadRadioStations,
                                           UIAction.hideProgressIndicator,
                                           fallbackAction: UIAction.hideProgressIndicator)
            Current.dispatch(action)
        }
    }
    
    override func viewWillLayout() {
        super.viewWillLayout()
        collectionView.collectionViewLayout?.invalidateLayout()
    }
    
    func selectStation(at index: Int) {
        let station = stations[index]
        
        let isPlayCurrentStation = Current.currentState.state.currentRadio?.radio == station
        let isPlayNow = Current.currentState.state.player?.isPlayingNow ?? false
        
        switch (isPlayCurrentStation, isPlayNow) {
        case (true, true): Current.dispatch(PlayerAction.pause)
        case (true, false): Current.dispatch(PlayerAction.resume)
        default: Current.dispatch(CompositeActions.play(station: station))
        }
    }
    
    func image(for radio: GMusicRadioStation) -> Observable<NSImage?> {
        guard let client = Current.currentState.state.client else { return Observable.just(nil) }
        guard let art = radio.imageUrls.first(where: { $0.autogen == false }) ?? radio.imageUrls.first else {
            return Observable.just(nil)
        }
        
        return client
            .downloadArt(art)
            .map { NSImage($0) }
            .asObservable()
    }
    
    deinit {
        print("RadioListController deinit")
    }
}

extension RadioListController: NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return stations.count
    }
    
    func collectionView(_ itemForRepresentedObjectAtcollectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item: RadioStationCollectionViewItem = collectionView.makeItem(for: indexPath)
        let station = stations[indexPath.item]
        
        item.title = station.name
        item.setImage(from: image(for: station))
        
        if let player = Current.currentState.state.player {
            item.subscribeToIsPlaying(player.isPlaying)
        }
        
        return item
    }
}
