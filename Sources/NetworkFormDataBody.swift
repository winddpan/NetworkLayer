//
//  NetworkFormDataBody.swift
//  NetworkLayer
//
//  Created by PAN on 2022/7/22.
//

import Foundation

public class NetworkFormDataBody: BodyConvertible {
    private var httpBody = NSMutableData()
    private let boundary: String = "Boundary-\(UUID().uuidString)"
    private lazy var boundaryEnd = "--\(boundary)--\r\n".data(using: .utf8)!

    public required init() {}

    public func convertToBodyData() -> Data? {
        return httpBody + boundaryEnd
    }

    public var headerFields: [String: String]? {
        return ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
    }

    @discardableResult
    public func addTextField(name: String, value: String) -> Self {
        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"\(name)\"\r\n")
        append("\r\n")
        append(value)
        append("\r\n")

        return self
    }

    @discardableResult
    public func addDataField(name: String, fileName: String? = nil, mimeType: String? = nil, data: Data) -> Self {
        let fileNamePart = fileName == nil ? "" : "; filename=\"\(fileName!)\""

        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"\(name)\"\(fileNamePart)\r\n")
        if let mimeType = mimeType {
            append("Content-Type: \(mimeType)\r\n")
        } else {
            append("Content-Type: \"content-type header\"\r\n")
        }
        append("\r\n")
        append(data)
        append("\r\n")

        return self
    }

    private func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            httpBody.append(data)
        }
    }

    private func append(_ data: Data) {
        httpBody.append(data)
    }
}
