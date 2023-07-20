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

public extension TypedEndpoint {
    @discardableResult
    func request(in provider: NetworkProvider<Self> = .init(maxAge: .never)) async throws -> ModelType {
        let response = try await provider.request(self)
        let model = try response.map(ModelType.self, atKeyPath: modelKeyPath)
        return model
    }
}
