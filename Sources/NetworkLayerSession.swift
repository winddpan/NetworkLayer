//
//  NetworkLayerSession.swift
//  NetworkLayer
//
//  Created by PAN on 2022/7/12.
//

import Foundation

class NetworkLayerSession: NSObject, URLSessionDelegate {
    static let shared = NetworkLayerSession()

    private var _session: URLSession!
    var session: URLSession {
        _session
    }

    override init() {
        super.init()
        renewSession()
    }

    func renewSession() {
        _session = URLSession(configuration: NetworkLayerConfig.default.urlSessionConfiguration, delegate: self, delegateQueue: .main)
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        if let authenticationChallenge = NetworkLayerConfig.default.authenticationChallenge {
            return await authenticationChallenge(session, challenge)
        }
        return (URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
    }
}
