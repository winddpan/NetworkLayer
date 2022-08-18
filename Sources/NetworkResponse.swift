import Foundation

public struct NetworkResponse {
    public let data: Data
    public let response: HTTPURLResponse

    public var statusCode: Int {
        response.statusCode
    }

    public init(data: Data, response: HTTPURLResponse) {
        self.data = data
        self.response = response
    }
}
