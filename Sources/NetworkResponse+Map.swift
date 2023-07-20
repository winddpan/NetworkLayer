import Foundation
#if os(iOS)
    import UIKit
#endif

public extension NetworkResponse {
    #if os(iOS)
        /// Maps data received from the signal into an Image.
        func mapImage() throws -> UIImage {
            guard let image = UIImage(data: data) else {
                throw RequestError.decodeFailure
            }
            return image
        }
    #endif

    /// Maps data received from the signal into a JSON object.
    ///
    /// - parameter failsOnEmptyData: A Boolean value determining
    /// whether the mapping should fail if the data is empty.
    func mapJSON(failsOnEmptyData: Bool = true) throws -> Any {
        do {
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            if data.isEmpty, !failsOnEmptyData {
                return NSNull()
            }
            throw RequestError.decodeFailure
        }
    }

    func mapDictionary() throws -> [String: Any] {
        do {
            let obj = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dict = obj as? [String: Any] {
                return dict
            }
            throw RequestError.decodeFailure
        } catch {
            throw RequestError.decodeFailure
        }
    }

    func debug(_ prefix: String? = nil) -> Self {
        #if DEBUG
            do {
                let string = try mapString()
                print(prefix ?? "", string)
            } catch {
                print("NetworkResponse debug:", error)
            }
        #endif
        return self
    }

    /// Maps data received from the signal into a String.
    ///
    /// - parameter atKeyPath: Optional key path at which to parse string.
    func mapString(atKeyPath keyPath: String? = nil) throws -> String {
        if let keyPath = keyPath {
            // Key path was provided, try to parse string at key path
            guard let jsonDictionary = try mapJSON() as? NSDictionary,
                  let string = jsonDictionary.value(forKeyPath: keyPath) as? String
            else {
                throw RequestError.decodeFailure
            }
            return string
        } else {
            // Key path was not provided, parse entire response as string
            guard let string = String(data: data, encoding: .utf8) else {
                throw RequestError.decodeFailure
            }
            return string
        }
    }

    /// Maps data received from the signal into a Decodable object.
    ///
    /// - parameter atKeyPath: Optional key path at which to parse object.
    /// - parameter using: A `JSONDecoder` instance which is used to decode data to an object.
    func map<D: Decodable>(_: D.Type, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true) throws -> D {
        let serializeToData: (Any) throws -> Data? = { jsonObject in
            guard JSONSerialization.isValidJSONObject(jsonObject) else {
                return nil
            }
            return try JSONSerialization.data(withJSONObject: jsonObject)
        }
        let jsonData: Data
        keyPathCheck: if let keyPath = keyPath {
            guard let jsonObject = try (mapJSON(failsOnEmptyData: failsOnEmptyData) as? NSDictionary)?.value(forKeyPath: keyPath) else {
                if failsOnEmptyData {
                    throw RequestError.decodeFailure
                } else {
                    jsonData = data
                    break keyPathCheck
                }
            }

            if let data = try serializeToData(jsonObject) {
                jsonData = data
            } else {
                let wrappedJsonObject = ["value": jsonObject]
                let wrappedJsonData: Data
                if let data = try serializeToData(wrappedJsonObject) {
                    wrappedJsonData = data
                } else {
                    throw RequestError.decodeFailure
                }
                return try decoder.decode(DecodableWrapper<D>.self, from: wrappedJsonData).value
            }
        } else {
            jsonData = data
        }
        if jsonData.isEmpty, !failsOnEmptyData {
            if let emptyJSONObjectData = "{}".data(using: .utf8), let emptyDecodableValue = try? decoder.decode(D.self, from: emptyJSONObjectData) {
                return emptyDecodableValue
            } else if let emptyJSONArrayData = "[{}]".data(using: .utf8), let emptyDecodableValue = try? decoder.decode(D.self, from: emptyJSONArrayData) {
                return emptyDecodableValue
            }
        }
        return try decoder.decode(D.self, from: jsonData)
    }
}

private struct DecodableWrapper<T: Decodable>: Decodable {
    let value: T
}

public extension Decodable {
    func debug() -> Self {
        #if DEBUG
            print(self)
        #endif
        return self
    }
}
