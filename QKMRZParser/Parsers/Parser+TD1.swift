//
//  Parser+TD1.swift
//  QKMRZParser
//
//  Created by Matej Dorcak on 14/10/2018.
//

import Foundation

extension Parsers {
    struct TD1: Parser {
        static let shared = TD1()
        static let lineLength = 30

        private init() {}

        // MARK: Parser
        func parse(mrzLines: [String], using formatter: MRZFieldFormatter) -> QKMRZResult {
            let (firstLine, secondLine, thirdLine) = (mrzLines[0], mrzLines[1], mrzLines[2])

            // MARK: Line #1
            let documentType = formatter.field(.documentType, from: firstLine, at: 0, length: 2)
            let countryCode = formatter.field(.countryCode, from: firstLine, at: 2, length: 3)
            let documentNumber = formatter.field(.documentNumber, from: firstLine, at: 5, length: 9, checkDigitFollows: true)
            let optionalData = formatter.field(.optionalData, from: firstLine, at: 15, length: 15)

            // MARK: Line #2
            let birthdate = formatter.field(.birthdate, from: secondLine, at: 0, length: 6, checkDigitFollows: true)
            let sex = formatter.field(.sex, from: secondLine, at: 7, length: 1)
            let expiryDate = formatter.field(.expiryDate, from: secondLine, at: 8, length: 6, checkDigitFollows: true)
            let nationality = formatter.field(.nationality, from: secondLine, at: 15, length: 3)
            let optionalData2 = formatter.field(.optionalData, from: secondLine, at: 18, length: 11)
            let finalCheckDigit = formatter.field(.hash, from: secondLine, at: 29, length: 1)

            // MARK: Line #3
            let names = formatter.field(.names, from: thirdLine, at: 0, length: 30)
            let (surnames, givenNames) = names.value as! (String, String)

            // MARK: Check Digit
            let allCheckDigitsValid = validateCheckDigits(
                documentNumber: documentNumber,
                optionalData: optionalData,
                birthdate: birthdate,
                expiryDate: expiryDate,
                optionalData2: optionalData2,
                finalCheckDigit: finalCheckDigit
            )

            // MARK: Result
            return .genericDocument(.init(
                documentType: documentType.value as! String,
                countryCode: countryCode.value as! String,
                surnames: surnames,
                givenNames: givenNames,
                documentNumber: documentNumber.value as! String,
                nationalityCountryCode: nationality.value as! String,
                birthdate: birthdate.value as! Date?,
                sex: sex.value as! String?,
                expiryDate: expiryDate.value as! Date?,
                personalNumber: optionalData.value as! String,
                personalNumber2: (optionalData2.value as! String),
                isDocumentNumberValid: documentNumber.isValid!,
                isBirthdateValid: birthdate.isValid!,
                isExpiryDateValid: expiryDate.isValid!,
                isPersonalNumberValid: nil,
                allCheckDigitsValid: allCheckDigitsValid
            ))
        }

        // MARK: Private
        private func validateCheckDigits(documentNumber: MRZField, optionalData: MRZField, birthdate: MRZField, expiryDate: MRZField, optionalData2: MRZField, finalCheckDigit: MRZField) -> Bool {
            let compositedValue = [documentNumber, optionalData, birthdate, expiryDate, optionalData2].reduce("", { ($0 + $1.rawValue + ($1.checkDigit ?? "")) })
            let isCompositedValueValid = MRZField.isValueValid(compositedValue, checkDigit: finalCheckDigit.rawValue)
            return (documentNumber.isValid! && birthdate.isValid! && expiryDate.isValid! && isCompositedValueValid)
        }
    }
}
