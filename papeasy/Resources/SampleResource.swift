//
//  SampleResource.swift
//  papeasy
//
//  Created by Ethan Silver on 2023-11-05.
//

import Foundation

class SampleResource: DynamicResource<Sample> {
  override func send() async throws {
    try await super.send()
    
    if let model = model {
      path.append(model.id)
    }
  }
}
