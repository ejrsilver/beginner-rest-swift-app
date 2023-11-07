//
//  User.swift
//  papeasy
//
//  Created by Ethan Silver on 2023-11-04.
//

struct User: Identifiable, Codable {
  let id: Int
  var first_name: String?
  var last_name: String?
  var email: String
  var locale: String
}

struct UserCredentials: Codable {
  let first_name: String?
  let last_name: String?
  let email: String
  let locale: String?
  let password: String
}
