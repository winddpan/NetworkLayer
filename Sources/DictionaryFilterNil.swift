//
//  DictionaryFilterNil.swift
//  NetworkLayer
//
//  Created by PAN on 2022/7/12.
//

import Foundation

func unwrap(any: Any) -> Any {
    let mi = Mirror(reflecting: any)
    if mi.displayStyle != .optional {
        return any
    }
    if mi.children.isEmpty { return NSNull() }
    let (_, some) = mi.children.first!
    return some
}

extension Dictionary {
    func filterNilValue<Wrapped>() -> [Key: Wrapped] where Value == Wrapped? {
        var result: [Key: Wrapped] = [:]
        for (key, value) in self {
            if let value = value {
                result[key] = value
            }
        }
        return result
    }
}
