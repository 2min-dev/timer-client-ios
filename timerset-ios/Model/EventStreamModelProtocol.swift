//
//  EventStreamModelProtocol.swift
//  timerset-ios
//
//  Created by JSilver on 23/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift

var streams: [String : Any] = [:]

protocol EventStreamProtocol {
    associatedtype Event
    
    var event: PublishSubject<Event> { get }
}

extension EventStreamProtocol {
    var event: PublishSubject<Event> {
        let key = String(describing: self)
        if let stream = streams[key] as? PublishSubject<Event> {
            return stream
        }
        
        let stream = PublishSubject<Event>()
        streams[key] = stream
        return stream
    }
}
