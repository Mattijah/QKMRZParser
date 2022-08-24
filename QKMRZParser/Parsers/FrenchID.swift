//
//  FrenchID.swift
//  QKMRZParser
//
//  Created by Matej Dorcak on 20/08/2022.
//

import Foundation

class FrenchID {
    static let lineLength = 36
    fileprivate let compositeCheckDigit: String
    fileprivate let finalCompositeCheckDigit: String

    let documentType: MRZField
    let countryCode: MRZField
    let lastName: MRZField
    let issuanceDepartment: MRZField
    let issuanceOffice: MRZField
    let issueDate: MRZField
    let issuanceDepartment2: MRZField
    let documentNumber: MRZField
    let firstName: MRZField
    let birthdate: MRZField
    let sex: MRZField

    fileprivate lazy var allCheckDigitsValid: Bool = {
        let allValues = [
            documentType,
            countryCode,
            lastName,
            issuanceDepartment,
            issuanceOffice,
            issueDate,
            issuanceDepartment2,
            documentNumber,
            firstName,
            birthdate,
            sex
        ]

        let compositedValue = [issueDate, issuanceDepartment2, documentNumber].reduce("", { ($0 + $1.rawValue) })
        let isCompositedValueValid = MRZField.isValueValid(compositedValue, checkDigit: compositeCheckDigit)

        let finalCompositedValue = allValues.reduce("", { ($0 + $1.rawValue) + ($1.checkDigit ?? "") })
        let isFinalCompositedValueValid = MRZField.isValueValid(finalCompositedValue, checkDigit: finalCompositeCheckDigit)

        return (birthdate.isValid! && isCompositedValueValid && isFinalCompositedValueValid)
    }()

    lazy var result: QKMRZResult = {
        let (firstName, givenNames) = firstName.value as! (String, String)
        let firstNameCombined = "\(firstName) \(givenNames)".trimmingCharacters(in: .whitespaces)

        return .frenchID(.init(
            documentType: documentType.value as! String,
            countryCode: countryCode.value as! String,
            lastName: lastName.value as! String,
            issuanceDepartment: (issuanceDepartment.value as! String).nilIfEmpty,
            issuanceOffice: (issuanceOffice.value as! String).nilIfEmpty,
            issueDate: issueDate.value as! String,
            issuanceDepartment2: issuanceDepartment2.value as! String,
            documentNumber: documentNumber.value as! String,
            firstName: firstNameCombined,
            birthdate: birthdate.value as! Date,
            sex: sex.value as! String,
            allCheckDigitsValid: allCheckDigitsValid
        ))
    }()

    init(from mrzLines: [String], using formatter: MRZFieldFormatter) {
        let (firstLine, secondLine) = (mrzLines[0], mrzLines[1])

        documentType = formatter.field(.documentType, from: firstLine, at: 0, length: 2)
        countryCode = formatter.field(.countryCode, from: firstLine, at: 2, length: 3)
        lastName = formatter.field(.alphabetic, from: firstLine, at: 5, length: 25)
        issuanceDepartment = formatter.field(.alphanumeric, from: firstLine, at: 30, length: 3)
        issuanceOffice = formatter.field(.numeric, from: firstLine, at: 33, length: 3)

        issueDate = formatter.field(.numeric, from: secondLine, at: 0, length: 4)
        issuanceDepartment2 = formatter.field(.alphanumeric, from: secondLine, at: 4, length: 3)
        documentNumber = formatter.field(.numeric, from: secondLine, at: 7, length: 5, checkDigitFollows: true)
        compositeCheckDigit = formatter.field(.hash, from: secondLine, at: 12, length: 1).rawValue
        firstName = formatter.field(.names, from: secondLine, at: 13, length: 14)
        birthdate = formatter.field(.birthdate, from: secondLine, at: 27, length: 6, checkDigitFollows: true)
        sex = formatter.field(.sex, from: secondLine, at: 34, length: 1)
        finalCompositeCheckDigit = formatter.field(.hash, from: secondLine, at: 35, length: 1).rawValue
    }

    class func validate(mrzLines: [String]) -> Bool {
        guard mrzLines.count == 2 else {
            return false
        }

        let mrz = mrzLines.joined()
        let matchesString = mrz.range(of: "^IDFRA.{67}$", options: .regularExpression)

        return (matchesString != nil)
    }
}
