//
//  Model.swift
//
//
//  Created by Franco Solerio on 09/10/23.
//

import Foundation

class Episode {
    init(title: String?, guid: String, date: Date?) {
        self.title = title
        self.guid = guid
        self.date = date
    }
    
    let title: String?
    let guid: String
    let date: Date?
    var payments = [Payment]()
    
    var aggregatedStreamPayments: Bitcoin {
        return streamPayments.reduce(0) { $0 + $1.amount }
    }
    
    var aggregatedBoostPayments: Bitcoin {
        return boostPayments.reduce(0) { $0 + $1.amount }
    }
    
    var boostPayments: [Payment] {
        return payments.filter { $0.type == .boost }
    }
    
    var streamPayments: [Payment] {
        return payments.filter { $0.type == .stream }
    }
}

class User {
    init(name: String?) {
        self.name = name
    }
    let name: String?
    var episodes = [Episode]()
    
    var aggregatedStreamPayments: Bitcoin {
        return episodes.reduce(0, { $0 + $1.aggregatedStreamPayments})
    }
    
    var aggregatedBoostPayments: Bitcoin {
        return episodes.reduce(0, { $0 + $1.aggregatedBoostPayments})
    }
}

class Payment {
    init(type: ActionType, amount: Bitcoin, date: Date, message: String?, timestamp: Int?) {
        self.type = type
        self.amount = amount
        self.date = date
        self.message = message
        self.timestamp = timestamp
    }
    
    let type: ActionType
    let amount: Bitcoin
    let date: Date
    let message: String?
    let timestamp: Int?
}


extension Episode: PrettyPrintable {}
extension User: PrettyPrintable {}
extension Payment: PrettyPrintable {}
