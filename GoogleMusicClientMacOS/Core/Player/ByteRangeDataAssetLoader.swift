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
    private let loadRequest: (ClosedRange<Int>) -> Single<(Data, HTTPURLResponse)>
    private let assetType: AssetType
    
    private var bag = DisposeBag()
    
    init(type: AssetType, loadRequest: @escaping (ClosedRange<Int>) -> Single<(Data, HTTPURLResponse)>) {
        self.assetType = type
        self.loadRequest = loadRequest
    }
    
    deinit {
        print("ByteRangeDataAssetLoader deinit")
    }
}

extension ByteRangeDataAssetLoader: AVAssetResourceLoaderDelegate {
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        return handleLoadingRequest(loadingRequest)
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        bag = DisposeBag()
    }
}

private extension ByteRangeDataAssetLoader {
    func handleLoadingRequest(_ loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
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
        
        return request != nil
    }
    
    func handleInformationRequest(_ informationRequest: AVAssetResourceLoadingContentInformationRequest) -> Completable {
        informationRequest.contentType = assetType.rawValue
        informationRequest.isByteRangeAccessSupported = true
        return loadRequest(0...1)
            .map { contentLengthFromRange(for: $1) ?? 2 }
            .do(onSuccess: { informationRequest.contentLength = $0 })
            .asCompletable()
    }
    
    func handleDataRequest(_ dataRequest: AVAssetResourceLoadingDataRequest) -> Completable {
        let lower = Int(dataRequest.requestedOffset)
        let upper = lower + dataRequest.requestedLength - 1
        let range = (lower...upper)
        
        return loadRequest(range)
            .do(onSuccess: { dataRequest.respond(with: $0.0) })
            .asCompletable()
    }
}

func contentLengthFromRange(for response: HTTPURLResponse) -> Int64? {
    guard let header = response.allHeaderFields["Content-Range"] as? String else { return nil }
    return Int64(header.split(separator: "/").last ?? "")
}
