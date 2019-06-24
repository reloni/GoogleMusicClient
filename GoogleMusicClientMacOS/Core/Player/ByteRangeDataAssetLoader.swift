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

private extension Observable where Element == (SessionDataEvent, URLSessionDataTask) {
    func ignoreElementsWithExtractedErrors() -> Completable {
        return Completable.create { observer in
            let errorOrComplete = { (error: Error?) in
                if let e = error {
                    observer(.error(e))
                } else {
                    observer(.completed)
                }
            }
            
            let subscription = self.subscribe(onNext: { result in
                switch result.0 {
                case let .didCompleteWithError(_, task, error) where task == result.1:
                    errorOrComplete(error)
                case .didBecomeInvalidWithError(_, let error):
                    errorOrComplete(error)
                default: break
                }
            })
            
            return Disposables.create {
                subscription.dispose()
            }
        }
    }
}

final class ByteRangeDataAssetLoader: NSObject {
    enum AssetType: String {
        case aac = "public.aac-audio"
    }
    
    private let createRequest: (ClosedRange<Int>) -> Single<URLRequest>
    private let assetType: AssetType
    private let sessionDelegate = NSURLSessionDataEventsObserver()
    private let session: URLSession
    private let errorsSubject: PublishSubject<Error>
    
    private var bag = DisposeBag()
    
    init(type: AssetType, errors: PublishSubject<Error>, createRequest: @escaping (ClosedRange<Int>) -> Single<URLRequest>) {
        self.assetType = type
        self.errorsSubject = errors
        self.createRequest = createRequest
        session = URLSession(configuration: .default, delegate: sessionDelegate, delegateQueue: nil)
    }
    
    deinit {
        print("ByteRangeDataAssetLoader deinit")
        session.invalidateAndCancel()
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
            .do(onError: { [weak self] in loadingRequest.finishLoading(with: $0); self?.errorsSubject.onNext($0) })
            .do(onCompleted: { loadingRequest.finishLoading() })
            .subscribe()
            .disposed(by: bag)
        
        return request != nil
    }
    
    func handleInformationRequest(_ informationRequest: AVAssetResourceLoadingContentInformationRequest) -> Completable {
        informationRequest.contentType = assetType.rawValue
        informationRequest.isByteRangeAccessSupported = true
        return createRequest(0...1)
            .map(session.dataTask)
            .asObservable()
            .flatMap(resume)
            .do(onNext: { result in
                guard case let .didReceiveResponse(_, task, response, completion) = result.0, task == result.1 else { return }
                informationRequest.contentLength = contentLengthFromRange(for: response as! HTTPURLResponse) ?? 2
                completion(.allow)
            })
            .ignoreElementsWithExtractedErrors()
    }
    
    func handleDataRequest(_ dataRequest: AVAssetResourceLoadingDataRequest) -> Completable {
        let lower = Int(dataRequest.requestedOffset)
        let upper = lower + dataRequest.requestedLength - 1
        let range = (lower...upper)
        
        return createRequest(range)
            .map(session.dataTask)
            .asObservable()
            .flatMap(resume)
            .do(onNext: { result in
                switch result.0 {
                case let .didReceiveResponse(_, task, _, completion) where task == result.1: completion(.allow)
                case let .didReceiveData(_, task, data) where task == result.1: dataRequest.respond(with: data)
                default: break
                }
            })
            .ignoreElementsWithExtractedErrors()
    }
    
    func resume(task: URLSessionDataTask) -> Observable<(SessionDataEvent, URLSessionDataTask)> {
        task.resume()
        return sessionDelegate.sessionEvents.map { ($0, task) }
    }
}

private func contentLengthFromRange(for response: HTTPURLResponse) -> Int64? {
    guard let header = response.allHeaderFields["Content-Range"] as? String else { return nil }
    return Int64(header.split(separator: "/").last ?? "")
}
