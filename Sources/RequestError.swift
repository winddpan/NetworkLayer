import Foundation

public enum RequestError: Error {
    case decodeFailure
    case invalidURL
    case noResponse
    case unauthorized
    case unexpectedStatusCode(Int)
}

public extension Swift.Error {
    var requestErrorStatusCode: Int? {
        if let e = self as? RequestError,
           case let RequestError.unexpectedStatusCode(code) = e
        {
            return code
        }
        return nil
    }
}
