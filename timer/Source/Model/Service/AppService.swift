//
//  AppService.swift
//  timer
//
//  Created by Jeong Jin Eun on 14/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift

enum AppEvent {
    
}

protocol AppServiceProtocol {
    var event: PublishSubject<AppEvent> { get }
    
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
}

class AppService: BaseService, AppServiceProtocol {
    // MARK: global state event
    var event: PublishSubject<AppEvent> = PublishSubject()
    
    // MARK: properties
    
    override init(provider: ServiceProviderProtocol) {
        super.init(provider: provider)
        
        registerUserDefaultDomain()
        Logger.debug("Background date: \(getBackgroundDate())", tag: "APP")
        Logger.debug("Running time set: \(getRunningTimeSet())", tag: "APP")
    }
    
    // MARK: - private method
    private func registerUserDefaultDomain() {
        provider.userDefaultService.register(defaults: [
            .timeSetId: 1,
            .countdown: 5,
            .alarm: 0
        ])
    }
    
    // MARK: - public method
    func setRunningTimeSet(_ runningTimeSet: RunningTimeSet?) {
        guard let runningTimeSet = runningTimeSet, let data = JSONCodec.encode(runningTimeSet) else {
            provider.userDefaultService.remove(key: .runningTimeSet)
            return
        }
        
        provider.userDefaultService.set(data, key: .runningTimeSet)
    }
    
    func getRunningTimeSet() -> RunningTimeSet? {
        guard let data: Data = provider.userDefaultService.object(.runningTimeSet) else { return nil }
        return JSONCodec.decode(data, type: RunningTimeSet.self)
    }
    
    func setBackgroundDate(_ date: Date) {
        provider.userDefaultService.set(date, key: .backgroundDate)
    }
    
    func getBackgroundDate() -> Date? {
        return provider.userDefaultService.object(.backgroundDate)
    }
    
    func setAlarm(_ alarm: Alarm) {
        provider.userDefaultService.set(alarm.rawValue, key: .alarm)
    }
    
    func getAlarm() -> Alarm {
        return Alarm(rawValue: provider.userDefaultService.integer(.alarm)) ?? .default
    }
    
    func setCountdown(_ countdown: Int) {
        provider.userDefaultService.set(countdown, key: .countdown)
    }
    
    func getCountdown() -> Int {
        return provider.userDefaultService.integer(.countdown)
    }
}
