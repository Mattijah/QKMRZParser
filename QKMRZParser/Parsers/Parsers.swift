//
//  Parsers.swift
//  QKMRZParser
//
//  Created by Matej Dorcak on 25/08/2022.
//

import Foundation

enum Parsers {
    static func parser(for mrzLines: [String]) -> Parser? {
        let lineLength = uniformedLineLength(for: mrzLines)

        switch mrzLines.count {
        case 2:
            switch lineLength {
            case TD2.lineLength, FrenchID.lineLength: // Both have an identical lineLength
                let isFrenchID = FrenchID.validate(mrzLines: mrzLines)
                return isFrenchID ? FrenchID.shared : TD2.shared
            case TD3.lineLength:
                return TD3.shared
            default:
                return nil
            }
        case 3 where lineLength == TD1.lineLength:
            return TD1.shared
        default:
            return nil
        }
    }

    private static func uniformedLineLength(for mrzLines: [String]) -> Int? {
        guard let lineLength = mrzLines.first?.count else {
            return nil
        }

        if mrzLines.contains(where: { $0.count != lineLength }) {
            return nil
        }

        return lineLength
    }
}
