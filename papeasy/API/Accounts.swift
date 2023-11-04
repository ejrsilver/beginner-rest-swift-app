//
//  Accounts.swift
//  papeasy
//
//  Created by Ethan Silver on 2023-11-02.
//

import Foundation

@MainActor
class Accounts: ObservableObject {
  @Published var me: User?
  
  init(me: User? = nil, auth: Auth? = nil) {
    guard let auth else {
      self.me = me
      return
    }
    Task {
      try await self.me(auth: auth)
    }
  }
  
  func signup(
    email: String,
    first_name: String,
    last_name: String,
    password: String
  ) async throws -> Void {
    guard var url = URL(string: "\(BaseURL)/accounts") else {
      throw HTTPError.URLError
    }
    url.append(queryItems: [
      URLQueryItem(name: "email", value: email),
      URLQueryItem(name: "first_name", value: first_name),
      URLQueryItem(name: "last_name", value: last_name),
      URLQueryItem(name: "password", value: password)
    ])

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let (data, resp) = try await URLSession.shared.data(for: request)
    guard let httpResponse = resp as? HTTPURLResponse else {
      throw HTTPError.ResponseError
    }
    
    guard httpResponse.statusCode == 200 else {
      let resp = try JSONDecoder().decode(ErrorResponse.self, from: data)
      throw HTTPError.Failure(message: "\(resp.message)")
    }
  }
  
  func me(auth: Auth) async throws -> Void {    
    guard let url = URL(string: "\(BaseURL)/accounts/me") else {
      throw HTTPError.URLError
    }
    
    var req = URLRequest(url: url)
    req.addValue("Bearer \(auth.token)", forHTTPHeaderField: "Authorization")
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let (data, resp) = try await URLSession.shared.data(for: req)
    guard let httpResponse = resp as? HTTPURLResponse else {
      throw HTTPError.ResponseError
    }
    
    guard httpResponse.statusCode == 200 else {
      let resp = try JSONDecoder().decode(ErrorResponse.self, from: data)
      throw HTTPError.Failure(message: "\(resp.message)")
    }
    me = try JSONDecoder().decode(User.self, from: data)
  }
}
