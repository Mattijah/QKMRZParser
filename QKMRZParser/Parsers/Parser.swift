//
//  Parser.swift
//  QKMRZParser
//
//  Created by Matej Dorcak on 24/08/2022.
//

import Foundation

protocol Parser {
    static var shared: Self { get }
    func parse(mrzLines: [String], using formatter: MRZFieldFormatter) -> QKMRZResult
}
