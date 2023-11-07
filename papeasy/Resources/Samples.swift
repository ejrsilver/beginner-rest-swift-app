//
//  Samples.swift
//  papeasy
//
//  Created by Ethan Silver on 2023-11-02.
//

import Foundation

@MainActor
class Samples: ObservableObject {
  @Published var samples: [Sample]?
  @Published var selectedSample: Sample?
  init(samples: [Sample]? = nil, auth: Auth? = nil) {
    guard let auth else {
      self.samples = samples
      return
    }
    Task {
      try await self.list(auth: auth)
    }
  }
  
  func list(auth: Auth) async throws -> Void {
    guard let url = URL(string: "\(PapEasyBaseURL)/samples") else {
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
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(DateFormatter.standard)
    samples = try decoder.decode([Sample].self, from: data)
  }
  
  func get(id: Int, auth: Auth) async throws -> Void {
    guard let url = URL(string: "\(PapEasyBaseURL)/samples/\(id)") else {
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
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(DateFormatter.standard)
    selectedSample = try decoder.decode(Sample.self, from: data)
  }
  
  func new(
    auth: Auth,
    device_id: String,
    patient_name: String = "",
    vial_id: String = "",
    container_id: String = "",
    test_date: Date = Date()
  ) async throws -> Void {
    guard var url = URL(string: "\(PapEasyBaseURL)/samples") else {
      throw HTTPError.URLError
    }
    
    var qItems = [URLQueryItem(name: "device_id", value: device_id)]
    if patient_name != "" {
      qItems.append(URLQueryItem(name: "patient_name", value: patient_name))
    }
    if vial_id != "" {
      qItems.append(URLQueryItem(name: "vial_id", value: vial_id))
    }
    if container_id != "" {
      qItems.append(URLQueryItem(name: "container_id", value: container_id))
    }
    if test_date != Date() {
      qItems.append(URLQueryItem(name: "test_date", value: test_date.ISO8601Format()))
    }
    
    url.append(queryItems: qItems)

    var req = URLRequest(url: url)
    req.httpMethod = "POST"
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
    
    // Invalidate Samples.
    samples = nil
  }
  
  func update(
    auth: Auth,
    id: String,
    device_id: String,
    patient_name: String = "",
    vial_id: String = "",
    container_id: String = "",
    test_date: Date = Date()
  ) async throws -> Void {
    guard var url = URL(string: "\(PapEasyBaseURL)/samples/\(id)") else {
      throw HTTPError.URLError
    }
    
    var qItems = [URLQueryItem(name: "device_id", value: device_id)]
    if patient_name != "" {
      qItems.append(URLQueryItem(name: "patient_name", value: patient_name))
    }
    if vial_id != "" {
      qItems.append(URLQueryItem(name: "vial_id", value: vial_id))
    }
    if container_id != "" {
      qItems.append(URLQueryItem(name: "container_id", value: container_id))
    }
    if test_date != Date() {
      qItems.append(URLQueryItem(name: "test_date", value: test_date.ISO8601Format()))
    }
    
    url.append(queryItems: qItems)

    var req = URLRequest(url: url)
    req.httpMethod = "PUT"
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
  }
}
