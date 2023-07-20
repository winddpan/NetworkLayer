import Foundation

public protocol TypedEndpoint: Endpoint {
    associatedtype ModelType: Decodable
    var modelType: (ModelType.Type, String?) { get }
}

public extension NetworkProvider where T: TypedEndpoint {
    @discardableResult
    func requestModel(_ endpoint: T) async throws -> T.ModelType {
        let response = try await request(endpoint)
        let model = try response.map(T.ModelType.self, atKeyPath: endpoint.modelType.1)
        return model
    }
}
