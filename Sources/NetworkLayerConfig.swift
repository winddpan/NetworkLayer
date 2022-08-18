import Foundation

public class NetworkLayerConfig {
    public static let `default` = NetworkLayerConfig()

    public var globalPlugins: [NetworkPlugin] = []

    public var urlSessionConfiguration: URLSessionConfiguration = .default {
        didSet {
            NetworkLayerSession.shared.renewSession()
        }
    }

    public var authenticationChallenge: ((_ session: URLSession, _ challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?))?

    public var shouldReturnSampleData: ((Endpoint) -> Bool)?
}
