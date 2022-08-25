//
//  QKMRZParser.swift
//  QKMRZParser
//
//  Created by Matej Dorcak on 14/10/2018.
//

import Foundation

public final class QKMRZParser {
    private let formatter: MRZFieldFormatter

    public init(ocrCorrection: Bool = false) {
        formatter = MRZFieldFormatter(ocrCorrection: ocrCorrection)
    }

    public func parse(mrzLines: [String]) -> QKMRZResult? {
        let parser = Parsers.parser(for: mrzLines)
        return parser?.parse(mrzLines: mrzLines, using: formatter)
    }
    
    public func parse(mrzString: String) -> QKMRZResult? {
        return parse(mrzLines: mrzString.components(separatedBy: "\n"))
    }
}
