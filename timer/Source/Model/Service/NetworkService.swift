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
    /// - endpoint: **~/app/version.json**
    func requestAppVersion() -> Single<AppVersion>
    
    /// Request notice list
    /// - endpoint: **~/notice/list.json**
    func requestNoticeList() -> Single<[Notice]>
    
    /// Request notice detail
    /// - endpoint: **~/notice/detail/id.json**
    /// - parameters:
    ///   - id: notice id
    func requestNoticeDetail(_ id: Int) -> Single<NoticeDetail>
}

class NetworkService: BaseService, NetworkServiceProtocol {
    func requestAppVersion() -> Single<AppVersion> {
        return ApiProvider<AppApi>.request(.version)
    }
    
    func requestNoticeList() -> Single<[Notice]> {
        return ApiProvider<NoticeApi>.request(.list)
    }
    
    func requestNoticeDetail(_ id: Int) -> Single<NoticeDetail> {
        return ApiProvider<NoticeApi>.request(.detail(id))
    }
}

struct ApiProvider<API: ApiType> {
    static func request<Model: Codable>(_ api: API) -> Single<Model> {
        Logger.info("request api : \(api.url.absoluteString)", tag: "NETWORK")
        
        return Single.create { emitter in
            DispatchQueue.global().async {
                AF.request(api.url,
                           method: api.method,
                           parameters: api.parameters,
                           headers: api.headers)
                    .response { data in
                        if let error = data.error {
                            Logger.error(error.errorDescription ?? "network error occured!", tag: "NETWORK")
                            emitter(.error(error))
                        }
                        
                        // Unwrap response data
                        guard let jsonData = data.data else {
                            emitter(.error(NetworkError.emptyData))
                            return
                        }

                        // Parse json data to model object
                        guard let model = JSONCodec.decode(jsonData, type: Model.self) else {
                            emitter(.error(NetworkError.parseError))
                            return
                        }
                        
                        // Emit succes through main thread
                        DispatchQueue.main.async {
                            emitter(.success(model))
                        }
                }
            }
            
            return Disposables.create()
        }
    }
}

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
        #if DEBUG
        return URL(string: "https://raw.githubusercontent.com/ChallengeProject/timer_api/develop/app")!
        #else
        return URL(string: "https://raw.githubusercontent.com/ChallengeProject/timer_api/master/app")!
        #endif
    }
    
    var path: String {
        switch self {
        case .version:
            return "/version.json"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: Parameters? {
        return nil
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}

// MARK: - notice api
enum NoticeApi: ApiType {
    // MARK: - api list
    case list
    case detail(Int)
    
    // MARK: - protocol implement
    var baseUrl: URL {
        #if DEBUG
        return URL(string: "https://raw.githubusercontent.com/ChallengeProject/timer_api/develop/notice")!
        #else
        return URL(string: "https://raw.githubusercontent.com/ChallengeProject/timer_api/master/notice")!
        #endif
    }
    
    var path: String {
        switch self {
        case .list:
            return "/list.json"
            
        case let .detail(id):
            return "/detail/\(id).json"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: Parameters? {
        return nil
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}
