//
//  AppService.swift
//  timer
//
//  Created by Jeong Jin Eun on 14/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation
import RxSwift

protocol AppServiceProtocol {
    // Running time set
    func setRunningTimeSet(_ runningTimeSet: RunningTimeSet?)
    func getRunningTimeSet() -> RunningTimeSet?
    
    // Background date
    func setBackgroundDate(_ date: Date)
    func getBackgroundDate() -> Date?
    
    // Default alarm
    func setAlarm(_ alarm: Alarm)
    func getAlarm() -> Alarm
    
    // Countdown
    func setCountdown(_ countdown: Int)
    func getCountdown() -> Int
    
    // Version
    func getVersion() -> Single<Version>
    
    // User Defaults
    func setTimeSetId(_ id: Int)
    
    // Notice
    func fetchNoticeList() -> Single<[Notice]>
    func fetchNoticeDetail(id: Int) -> Single<NoticeDetail>
}

class AppService: AppServiceProtocol {
    // MARK: - properties
    private var userDefaultService: UserDefaultServiceProtocol
    private var networkService: NetworkServiceProtocol
    
    // MARK: - constructor
    init(userDefault: UserDefaultServiceProtocol, network: NetworkServiceProtocol) {
        userDefaultService = userDefault
        networkService = network
        
        registerUserDefaultDomain()
    }
    
    // MARK: - private method
    private func registerUserDefaultDomain() {
        userDefaultService.register(defaults: [
            .timeSetId: 1,
            .countdown: 5,
            .alarm: 0
        ])
    }
    
    // MARK: - public method
    func setRunningTimeSet(_ runningTimeSet: RunningTimeSet?) {
        guard let runningTimeSet = runningTimeSet, let data = JSONCodec.encode(runningTimeSet) else {
            userDefaultService.remove(key: .runningTimeSet)
            return
        }
        
        userDefaultService.set(data, key: .runningTimeSet)
    }
    
    func getRunningTimeSet() -> RunningTimeSet? {
        guard let data: Data = userDefaultService.object(.runningTimeSet) else { return nil }
        return JSONCodec.decode(data, type: RunningTimeSet.self)
    }
    
    func setBackgroundDate(_ date: Date) {
        userDefaultService.set(date, key: .backgroundDate)
    }
    
    func getBackgroundDate() -> Date? {
        userDefaultService.object(.backgroundDate)
    }
    
    func setAlarm(_ alarm: Alarm) {
        userDefaultService.set(alarm.rawValue, key: .alarm)
    }
    
    func getAlarm() -> Alarm {
        Alarm(rawValue: userDefaultService.integer(.alarm)) ?? .default
    }
    
    func setCountdown(_ countdown: Int) {
        userDefaultService.set(countdown, key: .countdown)
    }
    
    func getCountdown() -> Int {
        userDefaultService.integer(.countdown)
    }
    
    func getVersion() -> Single<Version> {
        networkService.requestAppVersion()
    }
    
    func setTimeSetId(_ id: Int) {
        userDefaultService.set(id, key: .timeSetId)
    }
    
    func fetchNoticeList() -> Single<[Notice]> {
        networkService.requestNoticeList()
    }
    
    func fetchNoticeDetail(id: Int) -> Single<NoticeDetail> {
        networkService.requestNoticeDetail(id: id)
    }
}
