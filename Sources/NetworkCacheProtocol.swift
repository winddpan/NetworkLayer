//
//  NetworkCacheProtocol.swift
//  NetworkLayer
//
//  Created by PAN on 2022/9/29.
//

import Foundation

public enum NetworkMaxAge {
    case seconds(Int)
    case minutes(Int)
    case hours(Int)
    case days(Int)
    case never

    public var uptoSeconds: TimeInterval {
        switch self {
        case let .seconds(int):
            return TimeInterval(int)
        case let .minutes(int):
            return TimeInterval(int * 60)
        case let .hours(int):
            return TimeInterval(int * 3600)
        case let .days(int):
            return TimeInterval(int * 86400)
        case .never:
            return TimeInterval(0)
        }
    }
}

public protocol NetworkCacheProtocol {
    func removeAll()
    func remove(for endpoint: Endpoint)
    func object(for endpoint: Endpoint) -> Data?
    func setObject(_ data: Data, for endpoint: Endpoint, maxAge: NetworkMaxAge)
}

public extension Endpoint {
    func cacheKey() -> Int {
        var hasher = Hasher()
        hasher.combine(baseURL)
        hasher.combine(path)
        hasher.combine(method.rawValue)
        hasher.combine(header)
        hasher.combine(body?.convertToBodyData())
        return hasher.finalize()
    }
}
