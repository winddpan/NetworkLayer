//
//  XwwwFormURLEncoded.swift
//  NetworkLayer
//
//  Created by PAN on 2022/7/22.
//

import Foundation

public class XwwwFormURLEncoded: BodyConvertible {
    private var parameters: [String: Any] = [:]

    public required init(_ parameters: [String: Any]) {
        self.parameters = parameters
    }

    public func set(value: Any, forKey key: String) -> Self {
        parameters[key] = value
        return self
    }

    public func convertToBodyData() -> Data? {
        let str = (parameters as [String: Any?])
            .compactMapValues { $0 }
            .map { "\($0)=\($1)" }
            .joined(separator: "&")
        return str.data(using: .utf8)
    }

    public var headerFields: [String: String]? {
        return ["Content-Type": "application/x-www-form-urlencoded"]
    }
}
