//
//  CreateSamplePopup.swift
//
//  Created by Ethan Silver on 2023-11-03.
//

import Foundation
import SwiftUI
import Combine

struct CreateSampleView: View {
  @EnvironmentObject var auth: AuthResource
  @EnvironmentObject var samples: DynamicResource<[Sample]?>
  @ObservedObject var sample = DynamicResource<Sample>(from: Sample(patient_name: "", test_date: Date()), path: "/samples")
  @State private var patient_name: String = ""
  @State private var device_id: String = ""
  @State private var vial_id: String = ""
  @State private var container_id: String = ""
  @State private var test_date: Date = Date()
  @State private var isLoading = false
  @State var resp: String?
  
  @Binding var show: Bool
  
  private func onSampleCreate() async {
    guard auth.auth != nil else {
      resp = "You are not logged in."
      return
    }
    isLoading = true
    do {
      try await sample.send()
      resp = nil
      try await samples.retrieve()
      show = false
    } catch ResourceError.Failure(let message) {
      resp = "\(message)"
    } catch {
      resp = "\(error)"
    }
    isLoading = false
  }
  
  var body: some View {
    ZStack {
      VStack {
        if isLoading {
          ProgressView()
        } else {
          VStack {
            Text("Create Sample")
              .font(.title)
              .fontWeight(.semibold)
            TextField("Patient Name", text: $sample.model.patient_name)
            TextField("Device ID *", text: $device_id).modifier(NumericField(field: $device_id))
            TextField("Vial ID", text: $vial_id).modifier(NumericField(field: $vial_id))
            TextField("Container ID", text: $container_id).modifier(NumericField(field: $container_id))
            DatePicker("Test Date", selection: $sample.model.test_date)
            HStack {
              Button("Add Sample") {
                Task {
                  await onSampleCreate()
                }
              }.buttonStyle(.borderedProminent)
              Spacer()
              Button("Cancel") {
                show = false
              }.buttonStyle(.bordered)
            }.padding()
            if let resp = resp {
              VStack{
                Text(resp)
                  .fontWeight(.medium)
                  .foregroundColor(.black)
              }
              .padding(20)
              .background(Color(red: 1, green: 0.75, blue: 0.78))
              .clipShape(.buttonBorder)
            }
          }.padding(.all, 30.0)
            .task {
              if let auth = auth.model, sample.auth == nil {
                sample.setup(auth: auth)
              }
            }.refreshable {
              if let auth = auth.model, sample.auth == nil  {
                sample.setup(auth: auth)
              }
            }
        }
      }
    }
  }
}

#Preview {
  @State var isCreateLoading = false
  @State var isLoading = false
  
  return CreateSampleView(
    resp: "Invalid parameter(s): device_id",
    show: $isCreateLoading
  ).environmentObject(AuthResource())
}
