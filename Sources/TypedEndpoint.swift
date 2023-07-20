import Foundation

public struct TypedEndpoint<ModelType: Decodable>: Endpoint {
    public let baseURL: String
    public let path: String
    public let method: HTTPMethod
    public let header: [String: String]?
    public let body: BodyConvertible?
    public let modelKeyPath: String?

    public init(baseURL: String,
                path: String,
                method: HTTPMethod,
                header: [String: String]? = nil,
                body: BodyConvertible? = nil,
                modelType: ModelType.Type,
                modelKeyPath: String? = nil) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.header = header
        self.body = body
        self.modelKeyPath = modelKeyPath
    }
}

public extension NetworkProvider {
    @discardableResult
    func requestModel<M>(_ endpoint: T) async throws -> M where T == TypedEndpoint<M> {
        let response = try await request(endpoint)
        let model = try response.map(M.self, atKeyPath: endpoint.modelKeyPath)
        return model
    }
}
