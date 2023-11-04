//
//  Auth.swift
//  papeasy
//
//  Created by Ethan Silver on 2023-11-02.
//

import Foundation

class Authentication: ObservableObject {
  @Published var auth: Auth?
  private let apiKeychainKey = "papeasy-ios-key"
  
  init(auth: Auth? = nil) {
    self.auth = getTokenFromKeychain()
  }
  
  init(test: Bool) {
    self.auth = nil
  }
  
  @MainActor func login(
    email: String,
    password: String,
    rememberme: Bool
  ) async throws -> Void {
    guard var url = URL(string: "\(BaseURL)/auth/login") else {
      throw HTTPError.URLError
    }
    url.append(queryItems: [
      URLQueryItem(name: "email", value: email),
      URLQueryItem(name: "password", value: password),
      URLQueryItem(name: "rememberme", value: String(rememberme))
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
    
    let token = try JSONDecoder().decode(Auth.self, from: data)
    guard self.saveTokenToKeychain(token.token) else {
      throw AuthError.TokenSaveFailure
    }
    
    self.auth = token
    return
  }

  func logout() {
    if deleteTokenFromKeychain() {
      self.auth = nil
    }
  }
  
  func deleteTokenFromKeychain() -> Bool {
      let query = [
          kSecClass as String: kSecClassGenericPassword as String,
          kSecAttrAccount as String: self.apiKeychainKey,
      ] as CFDictionary

      let status = SecItemDelete(query)
      return status == errSecSuccess
  }

  func saveTokenToKeychain(_ token: String) -> Bool {
      let query = [
          kSecClass as String: kSecClassGenericPassword as String,
          kSecAttrAccount as String: apiKeychainKey,
          kSecValueData as String: token.data(using: .utf8)!
      ] as CFDictionary

      SecItemDelete(query)
      let status = SecItemAdd(query, nil)
      return status == errSecSuccess
  }
  
  func getTokenFromKeychain() -> Auth? {
      let query = [
          kSecClass as String: kSecClassGenericPassword as String,
          kSecAttrAccount as String: apiKeychainKey,
          kSecReturnData as String: kCFBooleanTrue!,
          kSecMatchLimit as String: kSecMatchLimitOne
      ] as CFDictionary

      var item: CFTypeRef?
      let status = SecItemCopyMatching(query, &item)
      
    if status == errSecSuccess, let data = item as? Data {
      guard let token = String(data: data, encoding: .utf8) else {
        return nil
      }
      return Auth(token: token)
    }
    else {
      return nil
    }
  }
}

