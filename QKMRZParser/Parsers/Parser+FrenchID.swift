//
//  Parser+FrenchID.swift
//  QKMRZParser
//
//  Created by Matej Dorcak on 20/08/2022.
//

import Foundation

// MARK: - FrenchID
extension Parsers {
    struct FrenchID: Parser {
        static let shared = FrenchID()
        static let lineLength = 36

        private init() {}

        static func validate(mrzLines: [String]) -> Bool {
            guard mrzLines.count == 2 else {
                return false
            }

            let mrz = mrzLines.joined()
            let matchesString = mrz.range(of: "^IDFRA.{67}$", options: .regularExpression)

            return (matchesString != nil)
        }

        // MARK: Parser
        func parse(mrzLines: [String], using formatter: MRZFieldFormatter) -> QKMRZResult {
            let (firstLine, secondLine) = (mrzLines[0], mrzLines[1])

            let fields = Fields(
                // MARK: Line #1
                documentType: formatter.field(.documentType, from: firstLine, at: 0, length: 2),
                countryCode: formatter.field(.countryCode, from: firstLine, at: 2, length: 3),
                lastName: formatter.field(.alphabetic, from: firstLine, at: 5, length: 25),
                issuanceDepartment: formatter.field(.alphanumeric, from: firstLine, at: 30, length: 3),
                issuanceOffice: formatter.field(.numeric, from: firstLine, at: 33, length: 3),

                // MARK: Line #2
                issueDate: formatter.field(.numeric, from: secondLine, at: 0, length: 4),
                issuanceDepartment2: formatter.field(.alphanumeric, from: secondLine, at: 4, length: 3),
                documentNumber: formatter.field(.numeric, from: secondLine, at: 7, length: 5, checkDigitFollows: true),
                compositeCheckDigit: formatter.field(.hash, from: secondLine, at: 12, length: 1),
                otherNames: formatter.field(.names, from: secondLine, at: 13, length: 14),
                birthdate: formatter.field(.birthdate, from: secondLine, at: 27, length: 6, checkDigitFollows: true),
                sex: formatter.field(.sex, from: secondLine, at: 34, length: 1),
                finalCompositeCheckDigit: formatter.field(.hash, from: secondLine, at: 35, length: 1)
            )

            let (firstName, givenNames) = fields.otherNames.value as! (String, String)

            // MARK: Result
            let firstNameCombined = "\(firstName) \(givenNames)".trimmingCharacters(in: .whitespaces)

            return .frenchID(.init(
                documentType: fields.documentType.value as! String,
                countryCode: fields.countryCode.value as! String,
                lastName: fields.lastName.value as! String,
                issuanceDepartment: (fields.issuanceDepartment.value as! String).nilIfEmpty,
                issuanceOffice: (fields.issuanceOffice.value as! String).nilIfEmpty,
                issueDate: fields.issueDate.value as! String,
                issuanceDepartment2: fields.issuanceDepartment2.value as! String,
                documentNumber: fields.documentNumber.value as! String,
                firstName: firstNameCombined,
                birthdate: fields.birthdate.value as! Date,
                sex: fields.sex.value as! String,
                allCheckDigitsValid: validateCheckDigits(fields: fields)
            ))
        }

        // MARK: Private
        private func validateCheckDigits(fields: Fields) -> Bool {
            // All values except the check digits
            let allValues = [
                fields.documentType,
                fields.countryCode,
                fields.lastName,
                fields.issuanceDepartment,
                fields.issuanceOffice,
                fields.issueDate,
                fields.issuanceDepartment2,
                fields.documentNumber,
                fields.otherNames,
                fields.birthdate,
                fields.sex
            ]

            let compositedValue = [fields.issueDate, fields.issuanceDepartment2, fields.documentNumber].reduce("", { ($0 + $1.rawValue) })
            let isCompositedValueValid = MRZField.isValueValid(compositedValue, checkDigit: fields.compositeCheckDigit.rawValue)

            let finalCompositedValue = allValues.reduce("", { ($0 + $1.rawValue) + ($1.checkDigit ?? "") })
            let isFinalCompositedValueValid = MRZField.isValueValid(finalCompositedValue, checkDigit: fields.finalCompositeCheckDigit.rawValue)

            return (fields.birthdate.isValid! && isCompositedValueValid && isFinalCompositedValueValid)
        }

    }
}

// MARK: - Fields
private struct Fields {
    let documentType: MRZField
    let countryCode: MRZField
    let lastName: MRZField
    let issuanceDepartment: MRZField
    let issuanceOffice: MRZField
    let issueDate: MRZField
    let issuanceDepartment2: MRZField
    let documentNumber: MRZField
    let compositeCheckDigit: MRZField
    let otherNames: MRZField
    let birthdate: MRZField
    let sex: MRZField
    let finalCompositeCheckDigit: MRZField
}
