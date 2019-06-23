//
//  DataAssetLoader.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 30/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import AVFoundation

enum AssetType: String {
    case aac = "public.aac-audio"
}

final class InMemoryDataAssetLoader: NSObject {
    private let data: Data
    private let assetType: AssetType
    
    init(_ data: Data, type: AssetType) {
        self.data = data
        self.assetType = type
    }
    
    deinit {
        print("InMemoryDataAssetLoader deinit")
    }
}

extension InMemoryDataAssetLoader: AVAssetResourceLoaderDelegate {
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        DispatchQueue.global(qos: .default).async {
            self.handleLoadingRequest(loadingRequest)
        }
        return true
    }
}

private extension InMemoryDataAssetLoader {
    func handleLoadingRequest(_ loadingRequest: AVAssetResourceLoadingRequest) {
        if let info = loadingRequest.contentInformationRequest {
            self.handleInformationRequest(info)
            loadingRequest.finishLoading()
        } else if let data = loadingRequest.dataRequest {
            self.handleDataRequest(data)
            loadingRequest.finishLoading()
        }
    }
    
    func handleInformationRequest(_ informationRequest: AVAssetResourceLoadingContentInformationRequest) {
        informationRequest.contentType = self.assetType.rawValue
        informationRequest.contentLength = Int64(data.count)
        informationRequest.isByteRangeAccessSupported = false
    }
    
    func handleDataRequest(_ dataRequest: AVAssetResourceLoadingDataRequest) {
        let lower = Int(dataRequest.requestedOffset)
        let upper = lower + dataRequest.requestedLength
        let range = (lower..<upper)
        dataRequest.respond(with: data.subdata(in: range))
    }
}
