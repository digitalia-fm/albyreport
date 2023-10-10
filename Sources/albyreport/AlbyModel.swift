//
//  Model.swift
//  
//
//  Created by Franco Solerio on 31/01/22.
//

import Foundation

public struct RequestInvoiceResponse: Codable {
    public let amount: Int
    public let boostagram: BoostagramResponse?
    public let comment: String?
    public let createdAt: String
    public let creationDate: Date
    public let currency: String
    public let customRecords: [String: String]?
    public let descriptionHash: JSONNull?
    public let expiresAt: String
    public let expiry: Int
    public let identifier: String
    public let keysendMessage: JSONNull?
    public let memo, payerName: String?
    public let payerPubkey: JSONNull?
    public let paymentHash, paymentRequest, rHashStr: String
    public let settled: Bool
    public let settledAt, state, type: String
    public let value: Int
    
    enum CodingKeys: String, CodingKey {
        case amount, boostagram
        case comment
        case createdAt = "created_at"
        case creationDate = "creation_date"
        case currency
        case customRecords = "custom_records"
        case descriptionHash = "description_hash"
        case expiresAt = "expires_at"
        case expiry, identifier
        case keysendMessage = "keysend_message"
        case memo
        case payerName = "payer_name"
        case payerPubkey = "payer_pubkey"
        case paymentHash = "payment_hash"
        case paymentRequest = "payment_request"
        case rHashStr = "r_hash_str"
        case settled
        case settledAt = "settled_at"
        case state, type, value
    }
}

public enum ActionType: String, Codable {
    case stream, boost
}

public struct BoostagramResponse: Codable {
    public let action: ActionType
    public let appName: String?
    public let boostLink: String?
    public let episode: String?
    public let episodeGuid: String?
    public let feedID, itemID: Int?
    public let message: String?
    public let name, podcast, senderID, senderName: String?
    public let time: String?
    public let ts: Int?
    public let url: String?
    public let valueMsatTotal: Int?
    
    enum CodingKeys: String, CodingKey {
        case action
        case appName = "app_name"
        case boostLink = "boost_link"
        case episode, feedID, itemID, message, name, podcast
        case episodeGuid = "episode_guid"
        case senderID = "sender_id"
        case senderName = "sender_name"
        case time, ts, url
        case valueMsatTotal = "value_msat_total"
    }
}

public class JSONNull: Codable, Hashable {
    
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(0)
    }
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}



protocol PrettyPrintable: CustomDebugStringConvertible {
    func prettyDescription(indenting: Int) -> String
}

extension PrettyPrintable {
    public func prettyDescription(indenting: Int) -> String  {
        var result = ""
        let mirror = Mirror(reflecting: self)
        
        result += "(" + String(describing: type(of: self)) + ")\n"
        for child in mirror.children {
            if let childValue = child.value as? PrettyPrintable {
                for _ in 0...indenting {
                    result += "\t"
                }
                result += child.label! + ": "
                result += childValue.prettyDescription(indenting: indenting + 1)
            } else {
                for _ in 0...indenting {
                    result += "\t"
                }
                result += "\(child.label!): \(child.value)\n"
            }
        }
        return result
    }
    
    public var debugDescription: String {
        return self.prettyDescription(indenting: 0)
    }
}

extension RequestInvoiceResponse: PrettyPrintable {}
extension BoostagramResponse: PrettyPrintable {}

