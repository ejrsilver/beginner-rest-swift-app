//
//  Models.swift
//  papeasy
//
//  Created by Ethan Silver on 2023-11-02.
//

import Foundation

let BaseURL = "http://127.0.0.1/wp-json/pap-api/v1"

enum HTTPError: Error {
  case URLError
  case ResponseError
  case Failure(message: String)
}

enum AuthError: Error {
  case TokenSaveFailure
}

struct Auth: Codable {
  let token: String
  
  init(token: String) {
    self.token = token
  }
}

struct User: Codable {
  let id: Int
  var first_name: String
  var last_name: String
  var email: String
  var locale: String
}

struct ErrorResponse: Codable {
  let code: String
  let message: String
}

struct Sample: Codable, Identifiable {
  let id: Int
  var patient_name: String
  var device_id: Int
  var vial_id: Int?
  var container_id: Int?
  var tracking_id: Int?
  var sample_status: Status = .Pending
  var sample_comments: String?
  var test_date: Date
  
  init(id: Int, patient_name: String, device_id: Int, vial_id: Int? = nil, container_id: Int? = nil, tracking_id: Int? = nil, sample_status: Status, sample_comments: String? = nil, test_date: Date) {
    self.id = id
    self.patient_name = patient_name
    self.device_id = device_id
    self.vial_id = vial_id
    self.container_id = container_id
    self.tracking_id = tracking_id
    self.sample_status = sample_status
    self.sample_comments = sample_comments
    self.test_date = test_date
  }
}

enum Status: String, Codable {
  case Pending = "Pending"
  case Positive = "Results Available: Positive"
  case Negative = "Results Available: Negative"
  case Undecided = "Results Available: Undecided"
}
