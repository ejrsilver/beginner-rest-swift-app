//
//  Sample.swift
//
//  Created by Ethan Silver on 2023-11-04.
//

import Foundation

struct Sample: Identifiable, RetrieveIdentifiable, Codable {
  var id: Int?
  var patient_name: String
  var device_id: Int?
  var vial_id: Int?
  var container_id: Int?
  var tracking_id: Int?
  var sample_status: Status = .Pending
  var sample_comments: String?
  var test_date: Date
  
  init(id: Int? = nil, patient_name: String, device_id: Int? = nil, vial_id: Int? = nil, container_id: Int? = nil, tracking_id: Int? = nil, sample_status: Status = .Pending, sample_comments: String? = nil, test_date: Date) {
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

  init() {
    patient_name = ""
    test_date = Date()
  }
}

enum Status: String, Codable {
  case Pending = "Pending"
  case Positive = "Results Available: Positive"
  case Negative = "Results Available: Negative"
  case Undecided = "Results Available: Undecided"
}
