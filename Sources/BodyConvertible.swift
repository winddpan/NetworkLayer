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

extension Dictionary: BodyConvertible where Key == String {
    public func convertToBodyData() -> Data? {
        var dictionary = self as [String: Any?]
        dictionary = dictionary.compactMapValues { $0 }
        return try? JSONSerialization.data(withJSONObject: dictionary, options: [])
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
