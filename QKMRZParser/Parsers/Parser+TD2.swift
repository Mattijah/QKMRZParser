//
//  Parser+TD2.swift
//  QKMRZParser
//
//  Created by Matej Dorcak on 14/10/2018.
//

import Foundation

extension Parsers {
    struct TD2: Parser {
        static let shared = TD2()
        static let lineLength = 36

        private init() {}

        // MARK: Parser
        func parse(mrzLines: [String], using formatter: MRZFieldFormatter) -> QKMRZResult {
            let (firstLine, secondLine) = (mrzLines[0], mrzLines[1])
            let isVisaDocument = (firstLine.substring(0, to: 0) == "V") // MRV-B type

            // MARK: Line #1
            let documentType = formatter.field(.documentType, from: firstLine, at: 0, length: 2)
            let countryCode = formatter.field(.countryCode, from: firstLine, at: 2, length: 3)
            let names = formatter.field(.names, from: firstLine, at: 5, length: 31)
            let (surnames, givenNames) = names.value as! (String, String)

            // MARK: Line #2
            let documentNumber = formatter.field(.documentNumber, from: secondLine, at: 0, length: 9, checkDigitFollows: true)
            let nationality = formatter.field(.nationality, from: secondLine, at: 10, length: 3)
            let birthdate = formatter.field(.birthdate, from: secondLine, at: 13, length: 6, checkDigitFollows: true)
            let sex = formatter.field(.sex, from: secondLine, at: 20, length: 1)
            let expiryDate = formatter.field(.expiryDate, from: secondLine, at: 21, length: 6, checkDigitFollows: true)
            let optionalData = formatter.field(.optionalData, from: secondLine, at: 28, length: isVisaDocument ? 8 : 7)
            let finalCheckDigit = isVisaDocument ? nil : formatter.field(.hash, from: secondLine, at: 35, length: 1)

            // MARK: Check Digit
            let allCheckDigitsValid = validateCheckDigits(
                documentNumber: documentNumber,
                birthdate: birthdate,
                expiryDate: expiryDate,
                optionalData: optionalData,
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
                personalNumber2: nil,
                isDocumentNumberValid: documentNumber.isValid!,
                isBirthdateValid: birthdate.isValid!,
                isExpiryDateValid: expiryDate.isValid!,
                isPersonalNumberValid: nil,
                allCheckDigitsValid: allCheckDigitsValid
            ))
        }

        // MARK: Private
        private func validateCheckDigits(documentNumber: MRZField, birthdate: MRZField, expiryDate: MRZField, optionalData: MRZField, finalCheckDigit: MRZField?) -> Bool {
            if let checkDigit = finalCheckDigit?.rawValue {
                let compositedValue = [documentNumber, birthdate, expiryDate, optionalData].reduce("", { ($0 + $1.rawValue + ($1.checkDigit ?? "")) })
                let isCompositedValueValid = MRZField.isValueValid(compositedValue, checkDigit: checkDigit)
                return (documentNumber.isValid! && birthdate.isValid! && expiryDate.isValid! && isCompositedValueValid)
            }
            else {
                return (documentNumber.isValid! && birthdate.isValid! && expiryDate.isValid!)
            }
        }
    }
}
