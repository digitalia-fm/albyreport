//
//  Bitcoin.swift
//  ValueBrowser
//
//  Created by Franco Solerio on 08/01/22.
//

import Foundation


// MARK: - Bitcoin

public struct Bitcoin {
    
    struct ConversionFactor {
        static let SatoshiToBTC = 0.000_000_01
        static let BTCToSatoshi = 1/SatoshiToBTC
    }
    
    public var value: Double = 0
    
    public init() {}
    
    public init(_ value: Double) {
        self.value = value
    }
    
    public init(_ value: Int) {
        self.value = Double(value)
    }
    
    public init(satoshis: Double) {
        self.value = Double(satoshis * ConversionFactor.SatoshiToBTC)
    }
    
    public init(satoshis: Int) {
        self.value = Double(satoshis) * ConversionFactor.SatoshiToBTC
    }
    
    public var toSatoshi: Double {
        let converted = self.value * ConversionFactor.BTCToSatoshi
        return converted
    }
    
    public var formattedSatoshiDescription: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        let numericString = numberFormatter.string(from: NSNumber(value: self.toSatoshi)) ?? "0"
        if numericString == "1" {
            return numericString + " sat"
        } else {
            return numericString + " sats"
        }
    }
}

extension Bitcoin: Equatable {}

extension Bitcoin: Comparable {
    public static func < (lhs: Bitcoin, rhs: Bitcoin) -> Bool {
        return lhs.value < rhs.value
    }
}

extension Bitcoin: AdditiveArithmetic {
    
    public static func - (lhs: Bitcoin, rhs: Bitcoin) -> Bitcoin {
        return Bitcoin(lhs.value - rhs.value)
    }
    
    
    public static func + (lhs: Bitcoin, rhs: Bitcoin) -> Bitcoin {
        return Bitcoin(lhs.value + rhs.value)
    }
    
    
    public static var zero: Bitcoin {
        return Bitcoin(0)
    }
    
}

extension Bitcoin: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int
    
    public init(integerLiteral value: Int) {
        self.value = Double(value)
    }
}

extension Bitcoin: ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = Double
    
    public init(floatLiteral value: Double) {
        self.value = value
    }
}

extension Bitcoin {
    public static func * (lhs: Bitcoin, rhs: Double) -> Bitcoin {
        return Bitcoin(lhs.value * rhs)
    }

    public static func *= (lhs: inout Bitcoin, rhs: Double) {
        lhs = lhs * rhs
    }
}

extension Bitcoin: Codable {}

extension Bitcoin: CustomStringConvertible {
    
    public var description: String {
        return String(format: "%0.1f sats", self.toSatoshi)
    }
    
}

extension Bitcoin: Strideable {
    public func distance(to other: Bitcoin) -> Double.Stride {
        return self.value.distance(to: other.value)
    }
    
    public func advanced(by n: Double.Stride) -> Bitcoin {
        return Bitcoin(self.value.advanced(by: n))
    }
    
    public typealias Stride = Double.Stride
}

extension Bitcoin: Numeric {
    public init?<T>(exactly source: T) where T : BinaryInteger {
        self.init(Double(source))
    }
    
    public var magnitude: Bitcoin {
        return Bitcoin(self.value.magnitude)
    }
    
    public static func * (lhs: Bitcoin, rhs: Bitcoin) -> Bitcoin {
        return Bitcoin(lhs.value * rhs.value)
    }
    
    public static func *= (lhs: inout Bitcoin, rhs: Bitcoin) {
        lhs.value *= rhs.value
    }
}

extension Bitcoin: FloatingPoint {
    public mutating func round(_ rule: FloatingPointRoundingRule) {
        value.round(rule)
    }
    
    public init(sign: FloatingPointSign, exponent: Double.Exponent, significand: Bitcoin) {
        self.value = Swift.Double(sign: sign, exponent: exponent, significand: significand.value)
    }
    
    public static var nan: Bitcoin {
        Self(Double.nan)
    }
    
    public static var signalingNaN: Bitcoin {
        Self(Double.signalingNaN)
    }
    
    public static var infinity: Bitcoin {
        Self(Double.infinity)
    }
    
    public static var greatestFiniteMagnitude: Bitcoin {
        Self(Double.greatestFiniteMagnitude)
    }
    
    public static var pi: Bitcoin {
        Self(Double.pi)
    }
    
    public var ulp: Bitcoin {
        Self(value.ulp)
    }
    
    public static var leastNormalMagnitude: Bitcoin {
        Self(Double.leastNormalMagnitude)
    }
    
    public static var leastNonzeroMagnitude: Bitcoin {
        Self(Double.leastNonzeroMagnitude)
    }
    
    public var sign: FloatingPointSign {
        return value.sign
    }
    
    public var exponent: Double.Exponent {
        value.exponent
    }
    
    public var significand: Bitcoin {
        Bitcoin(value.significand)
    }
    
    public static func / (lhs: Bitcoin, rhs: Bitcoin) -> Bitcoin {
        Bitcoin(lhs.value / rhs.value)
    }
    
    public static func /= (lhs: inout Bitcoin, rhs: Bitcoin) {
        lhs = Bitcoin(lhs.value/rhs.value)
    }
    
    public mutating func formRemainder(dividingBy other: Bitcoin) {
        value.formRemainder(dividingBy: other.value)
    }
    
    public mutating func formTruncatingRemainder(dividingBy other: Bitcoin) {
        value.formTruncatingRemainder(dividingBy: other.value)
    }
    
    public mutating func formSquareRoot() {
        value.formSquareRoot()
    }
    
    public mutating func addProduct(_ lhs: Bitcoin, _ rhs: Bitcoin) {
        value.addProduct(lhs.value, rhs.value)
    }
    
    public var nextUp: Bitcoin {
        Bitcoin(value.nextUp)
    }
    
    public func isEqual(to other: Bitcoin) -> Bool {
        value.isEqual(to: other.value)
    }
    
    public func isLess(than other: Bitcoin) -> Bool {
        value.isLess(than: other.value)
    }
    
    public func isLessThanOrEqualTo(_ other: Bitcoin) -> Bool {
        value.isLessThanOrEqualTo(other.value)
    }
    
    public var isNormal: Bool {
        value.isNormal
    }
    
    public var isFinite: Bool {
        value.isInfinite
    }
    
    public var isZero: Bool {
        value.isZero
    }
    
    public var isSubnormal: Bool {
        value.isSubnormal
    }
    
    public var isInfinite: Bool {
        value.isInfinite
    }
    
    public var isNaN: Bool {
        value.isNaN
    }
    
    public var isSignalingNaN: Bool {
        value.isSignalingNaN
    }
    
    public var isCanonical: Bool {
        value.isCanonical
    }
    
    public typealias Exponent = Double.Exponent
}

extension Bitcoin: BinaryFloatingPoint {
    public init(sign: FloatingPointSign, exponentBitPattern: Double.RawExponent, significandBitPattern: Double.RawSignificand) {
        self.value = Double(sign: sign, exponentBitPattern: exponentBitPattern, significandBitPattern: significandBitPattern)
    }
    
    public static var exponentBitCount: Int {
        Double.exponentBitCount
    }
    
    public static var significandBitCount: Int {
        Double.significandBitCount
    }
    
    public var exponentBitPattern: Double.RawExponent {
        value.exponentBitPattern
    }
    
    public var significandBitPattern: Double.RawSignificand {
        value.significandBitPattern
    }
    
    public var binade: Bitcoin {
        Bitcoin(value.binade)
    }
    
    public var significandWidth: Int {
        value.significandWidth
    }
    
    
    
    public typealias RawSignificand = Double.RawSignificand
    
    public typealias RawExponent = Double.RawExponent
    
    
}
