//
//  LoginModel.swift
//  Plumedot
//
//  Created by Md Faizul karim on 7/2/23.
//

import Foundation
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let loginModel = try? JSONDecoder().decode(LoginModel.self, from: jsonData)

import Foundation

// MARK: - LoginModel
struct LoginModel: Codable {
    let refresh, access: String?
}
