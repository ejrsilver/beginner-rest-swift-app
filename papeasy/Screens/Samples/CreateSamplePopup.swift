//
//  CreateSamplePopup.swift
//  papeasy
//
//  Created by Ethan Silver on 2023-11-03.
//

import Foundation
import SwiftUI
import Combine

struct CreateSamplePopup: View {
  @ObservedObject var auth: Authentication
  @ObservedObject var samples: Samples
  @State private var patient_name: String = ""
  @State private var device_id: String = ""
  @State private var vial_id: String = ""
  @State private var container_id: String = ""
  @State private var test_date: Date = Date()
  @State private var isLoading = false
  @State var resp: String?
  
  @Binding var show: Bool
  @Binding var isParentLoading: Bool
  var onLoad: () async -> Void
  
  private func onSampleCreate() async {
    guard let token = auth.auth else {
      resp = "You are not logged in."
      return
    }
    isLoading = true
    do {
      try await samples.new(
        auth: token,
        device_id: device_id,
        patient_name: patient_name,
        vial_id: vial_id,
        container_id: container_id,
        test_date: test_date
      )
      resp = "Sample Created!"
      show = false
      await onLoad()
    } catch HTTPError.Failure(let message) {
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
            TextField("Patient Name", text: $patient_name)
            TextField("Device ID *", text: $device_id).modifier(NumericField(field: $device_id))
            TextField("Vial ID", text: $vial_id).modifier(NumericField(field: $vial_id))
            TextField("Container ID", text: $container_id).modifier(NumericField(field: $container_id))
            DatePicker("Test Date", selection: $test_date)
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
        }
      }
    }
  }
}

struct NumericField: ViewModifier {
  @Binding var field: String
  func body(content: Content) -> some View {
    content
      .keyboardType(.numberPad)
      .onReceive(Just(field)) { newValue in
        let filtered = newValue.filter {
          "0123456789".contains($0)
        }
        if filtered != newValue {
          field = filtered
        }
      }
  }
}

#Preview {
  @State var isCreateLoading = false
  @State var isLoading = false
  @StateObject var auth = Authentication()
  @StateObject var samples = Samples()
  
  return CreateSamplePopup(
    auth: auth,
    samples: samples,
    resp: "Invalid parameter(s): device_id",
    show: $isCreateLoading,
    isParentLoading: $isLoading,
    onLoad: SamplesScreen(auth: auth, samples: samples).loadSamples
  )
}
