//
//  EventStreamModelProtocol.swift
//  timer
//
//  Created by JSilver on 23/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift

protocol EventStreamProtocol {
    associatedtype Event
    
    var event: PublishSubject<Event> { get }
}
