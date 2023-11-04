//
//  SampleView.swift
//  papeasy
//
//  Created by Ethan Silver on 2023-11-03.
//

import Foundation
import SwiftUI

struct SampleView: View {
  @State var sample: Sample

  var body: some View {
    VStack {
      Text("Sample ID: \(sample.id)")
      Text("Device ID: \(sample.device_id)")
      Text("Patient Name: \(sample.patient_name)")
      if let vial_id = sample.vial_id { Text("Vial ID: \(vial_id)") }
      if let container_id = sample.container_id { Text("Container ID: \(container_id)") }
      if let sample_comments = sample.sample_comments { Text("Sample Comments: \(sample_comments)") }
      Text("Sample Test Date: \(sample.test_date, format: Date.FormatStyle(date: .numeric, time: .standard))")
    }
  }
}

#Preview {
  @State var sample = Sample(
    id: 10, patient_name: "Hello",
    device_id: 10,
    sample_status: Status.Pending,
    test_date: Date()
  )
  @State var isLoading = false
  @StateObject var auth = Authentication()
  @StateObject var samples = Samples()
  
  return SampleView(sample: sample)
}
