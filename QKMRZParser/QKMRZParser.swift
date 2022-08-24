//
//  QKMRZParser.swift
//  QKMRZParser
//
//  Created by Matej Dorcak on 14/10/2018.
//

import Foundation

public class QKMRZParser {
    let formatter: MRZFieldFormatter
    
    enum MRZFormat: Int {
        case td1, td2, td3, frenchID, invalid
    }
    
    public init(ocrCorrection: Bool = false) {
        formatter = MRZFieldFormatter(ocrCorrection: ocrCorrection)
    }
    
    // MARK: Parsing
    public func parse(mrzLines: [String]) -> QKMRZResult? {
        let mrzFormat = self.mrzFormat(from: mrzLines)
        
        switch mrzFormat {
        case .td1:
            return TD1(from: mrzLines, using: formatter).result
        case .td2:
            return TD2(from: mrzLines, using: formatter).result
        case .td3:
            return TD3(from: mrzLines, using: formatter).result
        case .frenchID:
            return FrenchID(from: mrzLines, using: formatter).result
        case .invalid:
            return nil
        }
    }
    
    public func parse(mrzString: String) -> QKMRZResult? {
        return parse(mrzLines: mrzString.components(separatedBy: "\n"))
    }
    
    // MARK: MRZ-Format detection
    fileprivate func mrzFormat(from mrzLines: [String]) -> MRZFormat {
        switch mrzLines.count {
        case 2:
            let lineLength = uniformedLineLength(for: mrzLines)

            switch lineLength {
            case TD2.lineLength, FrenchID.lineLength: // Both have an identical lineLength
                let isFrenchID = FrenchID.validate(mrzLines: mrzLines)
                return isFrenchID ? .frenchID : .td2
            case TD3.lineLength:
                return .td3
            default:
                return .invalid
            }
        case 3:
            return (uniformedLineLength(for: mrzLines) == TD1.lineLength) ? .td1 : .invalid
        default:
            return .invalid
        }
    }
    
    fileprivate func uniformedLineLength(for mrzLines: [String]) -> Int? {
        guard let lineLength = mrzLines.first?.count else {
            return nil
        }
        
        if mrzLines.contains(where: { $0.count != lineLength }) {
            return nil
        }
        
        return lineLength
    }
}
