//
//  PayloadParsing.swift
//  FitLogWatch Watch App
//
//  P1-4 audit fix: Type-safe helpers for WCSession [String: Any] payloads
//  Centralizes NSNumber coercion (Flutter sends numbers as NSNumber via WCSession)
//

import Foundation

// MARK: - Dictionary Parsing Helpers

extension Dictionary where Key == String, Value == Any {

    /// Safely extract an Int, handling both Int and NSNumber from Flutter
    func intValue(for key: String) -> Int? {
        if let v = self[key] as? Int { return v }
        if let v = self[key] as? NSNumber { return v.intValue }
        return nil
    }

    /// Safely extract a Double, handling both Double and NSNumber from Flutter
    func doubleValue(for key: String) -> Double? {
        if let v = self[key] as? Double { return v }
        if let v = self[key] as? NSNumber { return v.doubleValue }
        return nil
    }

    /// Safely extract a Bool, handling both Bool and NSNumber from Flutter
    func boolValue(for key: String) -> Bool? {
        if let v = self[key] as? Bool { return v }
        if let v = self[key] as? NSNumber { return v.boolValue }
        return nil
    }

    /// Safely extract a String
    func stringValue(for key: String) -> String? {
        return self[key] as? String
    }

    /// Safely extract an optional String (returns nil if empty)
    func optionalString(for key: String) -> String? {
        guard let s = self[key] as? String, !s.isEmpty else { return nil }
        return s
    }

    /// Safely extract a String array
    func stringArray(for key: String) -> [String]? {
        return self[key] as? [String]
    }

    /// Safely extract an array of dictionaries
    func dictArray(for key: String) -> [[String: Any]]? {
        return self[key] as? [[String: Any]]
    }
}
