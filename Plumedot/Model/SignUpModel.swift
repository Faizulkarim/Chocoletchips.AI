//
//  SignUpModel.swift
//  Plumedot
//
//  Created by Md Faizul karim on 7/2/23.
//

import Foundation

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let signUpModel = try? JSONDecoder().decode(SignUpModel.self, from: jsonData)

import Foundation

// MARK: - SignUpModel
struct SignUpModel: Codable {
    let username, email, firstName, lastName: String?

    enum CodingKeys: String, CodingKey {
        case username, email
        case firstName = "first_name"
        case lastName = "last_name"
    }
}
