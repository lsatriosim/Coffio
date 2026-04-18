//
//  JSONCodable.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 05/04/26.
//

import Foundation

typealias JSONCodable = JSONEncodable & JSONDecodable
typealias JSONObject = [String: Any]

protocol JSONEncodable: Encodable {
    func toDictionary() -> JSONObject?
}

protocol JSONDecodable: Decodable {
    init(json: JSONObject) throws
}

extension JSONDecodable {
    init(json: JSONObject) throws {
        let data: Data = try JSONSerialization.data(withJSONObject: json, options: .init())
        self = try JSONDecoder().decode(Self.self, from: data)
    }
}

extension JSONEncodable {
    func toDictionary() -> JSONObject? {
        guard let data: Data = try? JSONEncoder().encode(self) else { return nil }
        
        guard let object = try? JSONSerialization.jsonObject(with: data, options: .init()) else { return nil }
        
        guard let jsonObject: JSONObject = object as? JSONObject else { return nil }
        
        return jsonObject
    }
}

protocol UnknownCaseRepresentable: RawRepresentable, Decodable where RawValue: Decodable {
    /// Fallback case when backend sends unknown value
    static var unknownCase: Self { get }
}

extension UnknownCaseRepresentable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(RawValue.self)
        self = Self(rawValue: rawValue) ?? Self.unknownCase
    }
}
