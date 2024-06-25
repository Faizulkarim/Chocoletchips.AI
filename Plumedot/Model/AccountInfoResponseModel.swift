//
//  AccountInfoResponseModel.swift
//  Plumedot
//
//  Created by Md Faizul karim on 7/2/23.
//


import Foundation

// MARK: - AccountInfoModel
struct AccountInfoModel: Codable {
    let success: Bool?
    let message: String?
    let data: [infoData]?
    let code: Int?
}

// MARK: - Datum
struct infoData: Codable {
    let id, nWord, nImg: Int?
    let createdAt, updatedAt: String?
    let user: Int?

    enum CodingKeys: String, CodingKey {
        case id, nWord, nImg
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case user
    }
}
