//
//  NSURLSessionDataEventsObserver.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 24/06/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Foundation
import RxSwift

enum SessionDataEvent {
    case didReceiveResponse(session: URLSession, dataTask: URLSessionDataTask, response: URLResponse,
        completion: (URLSession.ResponseDisposition) -> Void)
    case didReceiveData(session: URLSession, dataTask: URLSessionDataTask, data: Data)
    case didCompleteWithError(session: URLSession, dataTask: URLSessionTask, error: Error?)
    case didBecomeInvalidWithError(session: URLSession, error: Error?)
}

class NSURLSessionDataEventsObserver: NSObject {
    private let sessionEventsSubject = PublishSubject<SessionDataEvent>()
    
    var sessionEvents: Observable<SessionDataEvent> {
        return sessionEventsSubject
    }
    
    deinit {
        print("NSURLSessionDataEventsObserver deinit")
    }
}

extension NSURLSessionDataEventsObserver: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        sessionEventsSubject.onNext(.didReceiveResponse(session: session, dataTask: dataTask, response: response, completion: completionHandler))
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        sessionEventsSubject.onNext(.didReceiveData(session: session, dataTask: dataTask, data: data))
    }
}

extension NSURLSessionDataEventsObserver : URLSessionDelegate {
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        sessionEventsSubject.onNext(.didBecomeInvalidWithError(session: session, error: error))
    }
}

extension NSURLSessionDataEventsObserver : URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        sessionEventsSubject.onNext(.didCompleteWithError(session: session, dataTask: task, error: error))
    }
}
