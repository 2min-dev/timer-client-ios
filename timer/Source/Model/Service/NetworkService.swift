//
//  NetworkService.swift
//  timer
//
//  Created by JSilver on 2019/10/16.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

protocol NetworkServiceProtocol {
    /// Request app version
    /// - end-point: **~/v1/app/version.json**
    func requestAppVersion() -> Single<AppVersion>
    
    /// Request hot time set preset list
    /// - end-point: **~/v1/timeset/preset/hot.json**
    func requestHotPresets() -> Single<[TimeSetItem]>
    
    /// Request time set preset list
    /// - end-point: **~/v1/timeset/preset/list.json**
    func requestPresets() -> Single<[TimeSetItem]>
    
    /// Request notice list
    /// - end-point: **~/v1/notice/list.json**
    func requestNoticeList() -> Single<[Notice]>
    
    /// Request notice detail with id
    /// - end-point: **~/v1/notice/detail/id.json**
    /// - parameter id: notice identifier
    func requestNoticeDetail(_ id: Int) -> Single<NoticeDetail>
}

class NetworkService: NetworkServiceProtocol {
    // MARK: - server url
    enum Server {
        case github
        
        var url: URL {
            switch self {
            case .github:
                #if DEBUG
                return URL(string: "https://raw.githubusercontent.com/ChallengeProject/timer_api/develop")!
                #else
                return URL(string: "https://raw.githubusercontent.com/ChallengeProject/timer_api/master")!
                #endif
            }
        }
    }
    
    func requestAppVersion() -> Single<AppVersion> {
        ApiProvider<AppApi>.request(.version)
    }
    
    func requestHotPresets() -> Single<[TimeSetItem]> {
        ApiProvider<TimeSetApi>.request(.hot)
    }
    
    func requestPresets() -> Single<[TimeSetItem]> {
        ApiProvider<TimeSetApi>.request(.list)
    }
    
    func requestNoticeList() -> Single<[Notice]> {
        ApiProvider<NoticeApi>.request(.list)
    }
    
    func requestNoticeDetail(_ id: Int) -> Single<NoticeDetail> {
        ApiProvider<NoticeApi>.request(.detail(id))
    }
}

// MARK: - api provider
struct ApiProvider<API: ApiType> {
    static func request<Model: Codable>(_ api: API) -> Single<Model> {
        Logger.info(
            """
            API Request - \(api)
             🐶  URL: \(api.url.absoluteString)
             🐱  METHOD: \(api.method)
             🐭  PARAMETERS: \(api.parameters ?? [:])
             🐹  HEADER: \(api.headers ?? [])
            """,
            tag: "NETWORK"
        )
        
        return Single.create { emitter in
            AF.request(api.url, method: api.method, parameters: api.parameters, headers: api.headers)
                .response { result in
                    // Check network error
                    if let error = result.error {
                        Logger.error(error, tag: "NETWORK")
                        emitter(.error(NetworkError.unknown))
                        return
                    }
                    
                    // Unwrap response data
                    guard let data = result.data else {
                        emitter(.error(NetworkError.emptyData))
                        return
                    }
                    
                    Logger.debug(String(bytes: data, encoding: .utf8) ?? "", tag: "NETWORK")
                    
                    // Parse json data to model object
                    guard let model = JSONCodec.decode(data, type: Model.self) else {
                        emitter(.error(NetworkError.parseError))
                        return
                    }
                    
                    // Emit succes through main thread
                    emitter(.success(model))
            }
            
            return Disposables.create()
        }
    }
}

// MARK: - api type
protocol ApiType {
    /// Base url of api
    var baseUrl: URL { get }
    
    /// Specific path of api
    var path: String { get }
    
    /// Request method of http api
    var method: HTTPMethod { get }
    
    /// Parameters of http api
    var parameters: Parameters? { get }
    
    /// Header of http api
    var headers: HTTPHeaders? { get }
}

extension ApiType {
    var url: URL { baseUrl.appendingPathComponent(path) }
}

// MARK: - app api
enum AppApi: ApiType {
    // MARK: - api list
    case version
    
    // MARK: - protocol implement
    var baseUrl: URL {
        NetworkService.Server.github.url
    }
    
    var path: String {
        switch self {
        case .version:
            return "v1/app/version.json"
        }
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var parameters: Parameters? {
        nil
    }
    
    var headers: HTTPHeaders? {
        nil
    }
}

enum TimeSetApi: ApiType {
    // MARK: - api list
    case hot
    case list
    
    // MARK: - protocol implement
    var baseUrl: URL {
        NetworkService.Server.github.url
    }
    
    var path: String {
        switch self {
        case .hot:
            return "v1/timeset/preset/hot/\("localizable_server_flag".localized).json"
            
        case .list:
            return "v1/timeset/preset/list/\("localizable_server_flag".localized).json"
        }
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var parameters: Parameters? {
        nil
    }
    
    var headers: HTTPHeaders? {
        nil
    }
}

// MARK: - notice api
enum NoticeApi: ApiType {
    // MARK: - api list
    case list
    case detail(Int)
    
    // MARK: - protocol implement
    var baseUrl: URL {
        NetworkService.Server.github.url
    }
    
    var path: String {
        switch self {
        case .list:
            return "v1/notice/list.json"
            
        case let .detail(id):
            return "v1/notice/detail/\(id).json"
        }
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var parameters: Parameters? {
        nil
    }
    
    var headers: HTTPHeaders? {
        nil
    }
}
