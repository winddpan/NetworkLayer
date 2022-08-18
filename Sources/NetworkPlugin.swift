//
//  NetworkPlugin.swift
//  NetworkLayer
//
//  Created by PAN on 2022/7/7.
//

import Foundation

public protocol NetworkPlugin {
    func prepare(_ request: URLRequest, endpoint: Endpoint) -> URLRequest

    func willSend(_ request: URLRequest, endpoint: Endpoint)

    func didReceive(_ result: Result<NetworkResponse, Error>, endpoint: Endpoint)

    func process(_ result: Result<NetworkResponse, Error>, endpoint: Endpoint) -> Result<NetworkResponse, Error>
}

public extension NetworkPlugin {
    func prepare(_ request: URLRequest, endpoint _: Endpoint) -> URLRequest {
        return request
    }

    func willSend(_: URLRequest, endpoint _: Endpoint) {}

    func didReceive(_: Result<NetworkResponse, Error>, endpoint _: Endpoint) {}

    func process(_ result: Result<NetworkResponse, Error>, endpoint _: Endpoint) -> Result<NetworkResponse, Error> {
        return result
    }
}
