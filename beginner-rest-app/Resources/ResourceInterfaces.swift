//
//  Request.swift
//
//  Created by Ethan Silver on 2023-11-04.
//

import Foundation

let BaseURL = "http://127.0.0.1/wp-json/pap-api/v1"
let KeychainKey = "beginner-app-ios-key"

/// A type that can be retrieved with an identifier for updating.
protocol RetrieveIdentifiable {
  var id: Int? { get }
}
/// A type that can be retrieved in JSON encoding.
@MainActor protocol Retrievable {
  associatedtype ReturnType: Decodable
  var path: String { get }
  var auth: Auth? { get set }
  func retrieve(params: [URLQueryItem]?) async throws
}
/// A type that can be delivered in JSON encoding, with a JSON decodable return type.
protocol Creatable {
  associatedtype SendType: Encodable
  associatedtype ReturnType: Decodable
  var path: String { get }
  var auth: Auth? { get set }
  func send(forItem: SendType) async throws
}

/// A JSON-decodable observable resource that can be generated from a JSON-encodable resource.
class StaticResource<S: Encodable, R: Decodable>: ObservableObject, Creatable {
  typealias SendType = S
  typealias ReturnType = R
  
  @Published var model: R
  var path: String
  var auth: Auth?
  let formatter = DateFormatter()
  let decoder = JSONDecoder()
  let encoder = JSONEncoder()
  
  init(from: R, path: String) {
    self.path = path
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    
    decoder.dateDecodingStrategy = .formatted(formatter)
    encoder.dateEncodingStrategy = .formatted(formatter)
    model = from
  }
  
  func setup(auth: Auth) {
    self.auth = auth
  }
  
  /// Send the encodable resource. Sets the decodable response.
  @MainActor
  func send(forItem: S) async throws {
    let url = URL(string: "\(BaseURL)\(path)")!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    if let auth = auth {
      request.addValue("Bearer \(auth.token)", forHTTPHeaderField: "Authorization")
    }
    
    let encodedItem = try encoder.encode(forItem)
    
    let (data, resp) = try await URLSession.shared.upload(for: request, from: encodedItem)
    guard let httpResponse = resp as? HTTPURLResponse else {
      throw ResourceError.ResponseError
    }
    
    guard httpResponse.statusCode == 200 else {
      let resp = try decoder.decode(ErrorResponse.self, from: data)
      throw ResourceError.Failure(message: "\(resp.message)")
    }
    
    self.model = try decoder.decode(R.self, from: data)
  }
}

/// A Resource with a uniform codable observable object that can be retrieved, created, or updated.
class DynamicResource<T: Codable>: StaticResource<T, T>, Retrievable {
  /// Send the current model for updates.
  func send() async throws {
      /// If the resouce has an ID field but no ID (i.e. is yet to be created), send the request to create the object, then set the update request to include the resource's ID.
    if let obj = model as? RetrieveIdentifiable, obj.id == nil  {
      try await send(forItem: model)
      
      if let id = obj.id {
        path.append("/\(id)")
      }
    } else {
      try await send(forItem: model)
    }
  }
  
  /// Retrieve an up-to-date instance.
  func retrieve(params: [URLQueryItem]? = nil) async throws {
    var url = URL(string: "\(BaseURL)\(path)")!
    
    if let params = params {
      url.append(queryItems: params)
    }
    
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    if let auth = auth {
      request.addValue("Bearer \(auth.token)", forHTTPHeaderField: "Authorization")
    }
    
    let (data, resp) = try await URLSession.shared.data(for: request)
    guard let httpResponse = resp as? HTTPURLResponse else {
      throw ResourceError.ResponseError
    }
    
    guard httpResponse.statusCode == 200 else {
      let resp = try decoder.decode(ErrorResponse.self, from: data)
      throw ResourceError.Failure(message: "\(resp.message)")
    }
    
    self.model = try decoder.decode(T.self, from: data)
  }
}



