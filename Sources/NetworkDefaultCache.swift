//
//  NetworkDefaultCache.swift
//  NetworkLayer
//
//  Created by PAN on 2022/9/29.
//

import Foundation

open class NetworkDefaultCache: NetworkCacheProtocol {
    public let cache = NSCache<NSString, CacheObject>()

    public init() {
        cache.countLimit = 1000
        cache.totalCostLimit = 50 * 1000000
    }

    open func removeAll() {
        cache.removeAllObjects()
    }

    open func remove(for endpoint: Endpoint) {
        let key = NSString(string: "\(endpoint.cacheKey())")
        cache.removeObject(forKey: key)
    }

    open func object(for endpoint: Endpoint) -> Data? {
        let key = NSString(string: "\(endpoint.cacheKey())")
        if let cacheObj = cache.object(forKey: key) {
            if let overdue = cacheObj.overdue, overdue.timeIntervalSince(Date()) > 0 {
                return cacheObj.data
            } else {
                cache.removeObject(forKey: key)
                return nil
            }
        }
        return nil
    }

    open func setObject(_ data: Data, for endpoint: Endpoint, maxAge: NetworkMaxAge) {
        let key = NSString(string: "\(endpoint.cacheKey())")
        cache.setObject(CacheObject(data: data, overdue: overdueDate(maxAge)), forKey: key, cost: data.count)
    }

    private func overdueDate(_ maxAge: NetworkMaxAge) -> Date? {
        let seconds = maxAge.uptoSeconds
        if seconds > 0 {
            return Date().addingTimeInterval(seconds)
        }
        return nil
    }
}

public extension NetworkDefaultCache {
    class CacheObject {
        public let data: Data
        public let overdue: Date?

        public init(data: Data, overdue: Date?) {
            self.data = data
            self.overdue = overdue
        }
    }
}
