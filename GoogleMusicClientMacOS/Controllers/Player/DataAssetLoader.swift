//
//  DataAssetLoader.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 30/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import AVFoundation

final class DataAssetLoader: NSObject {
    enum AssetType: String {
        case aac = "public.aac-audio"
    }
    
    private var data: Data
    private var assetType: AssetType
    
    init(_ data: Data, type: AssetType) {
        self.data = data
        self.assetType = type
    }
    
    deinit {
        print("DataAssetLoader deinit")
    }
}

extension DataAssetLoader: AVAssetResourceLoaderDelegate {
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        DispatchQueue.global(qos: .default).async {
            self.handleLoadingRequest(loadingRequest)
        }
        return true
    }
}

private extension DataAssetLoader {
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
