//
//  PlagiarismModel.swift
//  Plumedot
//
//  Created by Md Faizul karim on 1/2/23.
//

import Foundation


public struct PlagiarismModel: Codable {
    let querywords: Int
    let cost: Double
    let count: Int
    let result: [Result]

    struct Result: Codable {
        let index: Int
        let url: String
        let title: String
        let textsnippet: String
        let htmlsnippet: String
        let minwordsmatched: Int
        let viewurl: String
    }
}
