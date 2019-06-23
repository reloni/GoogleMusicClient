//
//  ByteRangeDataAssetLoader.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 23/06/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Foundation
import AVFoundation
import RxSwift
import RxGoogleMusic

final class ByteRangeDataAssetLoader: NSObject {
    private let loadRequest: (Range<Int>) -> Single<GMusicRawResponse>
    private let assetType: AssetType
    
    private var bag = DisposeBag()
    
    init(type: AssetType, loadRequest: @escaping (Range<Int>) -> Single<GMusicRawResponse>) {
        self.assetType = type
        self.loadRequest = loadRequest
    }
    
    deinit {
        print("ByteRangeDataAssetLoader deinit")
    }
}

extension ByteRangeDataAssetLoader: AVAssetResourceLoaderDelegate {
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        DispatchQueue.global(qos: .default).async {
            self.handleLoadingRequest(loadingRequest)
        }
        return true
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        bag = DisposeBag()
    }
}

private extension ByteRangeDataAssetLoader {
    func handleLoadingRequest(_ loadingRequest: AVAssetResourceLoadingRequest) {
        let request: Completable? = {
            if let info = loadingRequest.contentInformationRequest {
                return handleInformationRequest(info)
            } else if let data = loadingRequest.dataRequest {
                return handleDataRequest(data)
            } else {
                return nil
            }
        }()
        
        request?
            .do(onError: { loadingRequest.finishLoading(with: $0) })
            .do(onCompleted: { loadingRequest.finishLoading() })
            .subscribe()
            .disposed(by: bag)
    }
    
    func handleInformationRequest(_ informationRequest: AVAssetResourceLoadingContentInformationRequest) -> Completable {
        informationRequest.contentType = assetType.rawValue
        informationRequest.isByteRangeAccessSupported = true
        return loadRequest(0..<2)
            .map { $0.response.expectedContentLength }
            .debug()
            .do(onSuccess: { informationRequest.contentLength = $0 })
            .asCompletable()
    }
    
    func handleDataRequest(_ dataRequest: AVAssetResourceLoadingDataRequest) -> Completable {
        let lower = Int(dataRequest.requestedOffset)
        let upper = lower + dataRequest.requestedLength
        let range = (lower..<upper)
        
        return loadRequest(range)
            .map { $0.data }
            .do(onSuccess: { dataRequest.respond(with: $0) })
            .asCompletable()
            .debug()
    }
}
