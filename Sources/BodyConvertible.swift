import Foundation

public protocol BodyConvertible {
    var headerFields: [String: String]? { get }
    func convertToBodyData() -> Data?
}

public extension BodyConvertible {
    var headerFields: [String: String]? {
        nil
    }
}

extension Dictionary: BodyConvertible where Key == String, Value == Any? {
    public func convertToBodyData() -> Data? {
        return try? JSONSerialization.data(withJSONObject: filterNilValue(), options: [])
    }
}

extension Array: BodyConvertible {
    public func convertToBodyData() -> Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: [])
    }
}

extension Data: BodyConvertible {
    public func convertToBodyData() -> Data? {
        return self
    }
}
