import Foundation

public protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var header: [String: String]? { get }
    var body: BodyConvertible? { get }
    var sampleData: Data? { get }
}

public extension Endpoint {
    var sampleData: Data? { nil }
}

public extension Endpoint {
    static func provider(plugins: [NetworkPlugin] = []) -> NetworkProvider<Self> {
        return NetworkProvider<Self>(plugins: plugins)
    }

    @discardableResult
    static func request(_ endpoint: Self) async throws -> NetworkResponse {
        return try await provider().request(endpoint)
    }
}
