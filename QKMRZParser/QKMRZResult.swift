//
//  QKMRZResult.swift
//  QKMRZParser
//
//  Created by Matej Dorcak on 14/10/2018.
//

import Foundation

// MARK: - QKMRZResult
public enum QKMRZResult {
    /// Any `TD1, TD2, TD3 or MRV-A, MRV-B` supported document (e.g. passport, visa, id).
    case genericDocument(GenericDocument)

    /// French ID only
    case frenchID(FrenchID)
}

// MARK: - GenericDocument
extension QKMRZResult {
    public struct GenericDocument {
        public let documentType: String
        public let countryCode: String
        public let surnames: String
        public let givenNames: String
        public let documentNumber: String
        public let nationalityCountryCode: String
        public let birthdate: Date? // `nil` if formatting failed
        public let sex: String? // `nil` if formatting failed
        public let expiryDate: Date? // `nil` if formatting failed
        public let personalNumber: String
        public let personalNumber2: String? // `nil` if not provided
        public let isDocumentNumberValid: Bool
        public let isBirthdateValid: Bool
        public let isExpiryDateValid: Bool
        public let isPersonalNumberValid: Bool?
        public let allCheckDigitsValid: Bool
    }
}

// MARK: - FrenchID
extension QKMRZResult {
    public struct FrenchID {
        public let documentType: String
        public let countryCode: String
        public let lastName: String
        public let issuanceDepartment: String?
        public let issuanceOffice: String?
        public let issueDate: String
        public let issuanceDepartment2: String
        public let documentNumber: String
        public let firstName: String
        public let birthdate: Date
        public let sex: String
        public let allCheckDigitsValid: Bool
    }
}
