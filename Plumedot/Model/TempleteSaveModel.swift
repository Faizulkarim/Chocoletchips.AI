//
//  TempleteSaveModel.swift
//  Plumedot
//
//  Created by Md Faizul karim on 7/2/23.
//

import Foundation

// MARK: - TempleteSaveModel
struct TempleteSaveModel: Codable {
    let success: Bool?
    let message: String?
    let data: [Datum]?
    let code: Int?
}

// MARK: - Datum
struct Datum: Codable {
    let id: Int?
    let title, brief, toneOfVoice, keywords: String?
    let outLength, emailContent, createdAt, updatedAt: String?
    let createdBy: Int?

    enum CodingKeys: String, CodingKey {
        case id, title, brief, toneOfVoice, keywords, outLength, emailContent
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case createdBy = "created_by"
    }
}


// MARK: - GetTempleteSaveModel
struct GetTempleteSaveModel: Codable {
    let success: Bool?
    let message: String?
    let data: [[Datum]]?
    let code: Int?
}



