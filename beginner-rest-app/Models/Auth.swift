//
//  Models.swift
//
//  Created by Ethan Silver on 2023-11-02.
//

import Foundation

struct Auth: Codable {
  let token: String
}

struct Login: Codable {
  var email: String,
  password: String,
  rememberme: Bool
}
