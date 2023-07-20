import Dispatch
import Foundation

public struct NetworkProvider<T: Endpoint> {
    public let maxAge: NetworkMaxAge
    public let plugins: [NetworkPlugin]

    public init(maxAge: NetworkMaxAge, plugins: [NetworkPlugin] = []) {
        self.maxAge = maxAge
        self.plugins = plugins
    }
}

public extension NetworkProvider {
    @discardableResult
    func request(_ endpoint: T) async throws -> NetworkResponse {
        lazy var path = endpoint.path
        lazy var body = endpoint.body
        lazy var header = endpoint.header
        lazy var method = endpoint.method
        lazy var sampleData = endpoint.sampleData
        lazy var baseURL = endpoint.baseURL

        guard let _url = URL(string: baseURL), var urlComps = URLComponents(url: _url, resolvingAgainstBaseURL: false) else {
            throw RequestError.invalidURL
        }

        urlComps.path = path.hasPrefix("/") ? path : "/\(path)"
        if method == .get, let params = body as? [String: Any?] {
            urlComps.queryItems = params.compactMapValues { $0 }.compactMap { key, value -> URLQueryItem? in
                let valueString = "\(value)"
                if !(value is NSNull), !valueString.isEmpty {
                    return URLQueryItem(name: key, value: valueString)
                }
                return nil
            }
        }
        guard let url = urlComps.url else {
            throw RequestError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        let allHTTPHeaderFields = (body?.headerFields ?? [:]).merging(header ?? [:]) { _, new in new }
        for (filed, value) in allHTTPHeaderFields {
            request.addValue(value, forHTTPHeaderField: filed)
        }
        switch method {
        case .get:
            break
        case .post:
            request.httpBody = body?.convertToBodyData()
        }

        let plugins = NetworkLayerConfig.default.globalPlugins + self.plugins
        plugins.forEach { request = $0.prepare(request, endpoint: endpoint) }
        plugins.forEach { $0.willSend(request, endpoint: endpoint) }

        let sessionResult: (Data?, URLResponse?, Error?)
        var sessionRequestRawData: Data?
        // Sample data
        if NetworkLayerConfig.default.shouldReturnSampleData?(endpoint) == true || ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1",
           let sampleData = sampleData {
            sessionResult = try await sessionWithSampleData(url: _url, data: sampleData, endpoint: endpoint)
        }
        // Cache data
        else if maxAge.uptoSeconds > 0, let cacheData = NetworkLayerConfig.default.cache.object(for: endpoint) {
            sessionResult = sessionWithCacheData(url: _url, data: cacheData, endpoint: endpoint)
        }
        // Request
        else {
            sessionResult = try await sessionDataTask(with: request)
            sessionRequestRawData = sessionResult.0
        }
        let result = try handleResult(endpoint: endpoint, result: sessionResult)

        // Save Cache
        if let sessionRequestRawData = sessionRequestRawData, maxAge.uptoSeconds > 0 {
            NetworkLayerConfig.default.cache.setObject(sessionRequestRawData, for: endpoint, maxAge: maxAge)
        }
        return result
    }

    private func handleResult(endpoint: T, result: (Data?, URLResponse?, Error?)) throws -> NetworkResponse {
        let data = result.0
        let response = result.1
        let error = result.2

        func handle(_ result: Result<NetworkResponse, Error>) throws -> NetworkResponse {
            var reResult = result
            let plugins = NetworkLayerConfig.default.globalPlugins + self.plugins
            plugins.forEach { reResult = $0.process(reResult, endpoint: endpoint) }
            plugins.forEach { $0.didReceive(reResult, endpoint: endpoint) }
            switch reResult {
            case let .success(res):
                return res
            case let .failure(err):
                throw err
            }
        }

        if let error = error {
            return try handle(.failure(error))
        }
        guard let data = data, let response = response as? HTTPURLResponse else {
            return try handle(.failure(RequestError.noResponse))
        }
        switch response.statusCode {
        case 200 ... 299:
            return try handle(.success(NetworkResponse(data: data, response: response)))
        case 401:
            return try handle(.failure(RequestError.unauthorized))
        default:
            return try handle(.failure(RequestError.unexpectedStatusCode(response.statusCode)))
        }
    }

    private func sessionDataTask(with request: URLRequest) async throws -> (Data?, URLResponse?, Error?) {
        return try await withCheckedThrowingContinuation { continuation in
            let session = NetworkLayerSession.shared.session
            let task = session.dataTask(with: request) { data, response, error in
                continuation.resume(returning: (data, response, error))
            }
            task.resume()
        }
    }

    private func sessionWithSampleData(url: URL, data: Data, endpoint: T) async throws -> (Data?, URLResponse?, Error?) {
        try await Task.sleep(nanoseconds: UInt64(0.1 * 1000000000))
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        return (data, response, nil)
    }

    private func sessionWithCacheData(url: URL, data: Data, endpoint: T) -> (Data?, URLResponse?, Error?) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        return (data, response, nil)
    }
}
