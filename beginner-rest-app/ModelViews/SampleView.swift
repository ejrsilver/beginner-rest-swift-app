//
//  SampleView.swift
//
//  Created by Ethan Silver on 2023-11-03.
//

import Foundation
import SwiftUI
import Combine

struct NumericField: ViewModifier {
  @Binding var field: String
  func body(content: Content) -> some View {
    content
      .keyboardType(.numberPad)
      .onReceive(Just(field)) { newValue in
        let filtered = String(newValue).filter {
          "0123456789".contains($0)
        }
        if filtered != newValue {
          field = filtered
        }
      }
  }
}

struct SampleView: View {
  @EnvironmentObject var auth: AuthResource
  @EnvironmentObject var samples: DynamicResource<[Sample]?>
  @ObservedObject var sample: DynamicResource<Sample>
  @State private var patient_name: String = ""
  @State private var device_id: String = ""
  @State private var vial_id: String = ""
  @State private var container_id: String = ""
  @State private var test_date = Date()
  @State private var isLoading = false
  @State private var edit = false
  @State var resp: String?

  func loadSample() async {
    guard let auth = auth.model else { return }
    sample.setup(auth: auth)
    isLoading = true
    do {
      try await sample.retrieve()
    } catch {
      print("\(error)")
    }
    isLoading = false
  }
    
  private func createSample() async {
    sample.model.patient_name = patient_name
    sample.model.device_id = Int(device_id)
    sample.model.vial_id = Int(vial_id)
    sample.model.container_id = Int(container_id)
    sample.model.test_date = test_date
    guard auth.model != nil else {
      resp = "You are not logged in."
      return
    }
    isLoading = true
    do {
      try await sample.send(forItem:
                              Sample(
                                patient_name: patient_name,
                                device_id: Int(device_id),
                                vial_id: Int(vial_id),
                                container_id: Int(container_id),
                                test_date: test_date
                              ))
      resp = nil
      try await samples.retrieve()
    } catch ResourceError.Failure(let message) {
      resp = "\(message)"
    } catch {
      resp = "\(error)"
    }
    isLoading = false
  }
  
  var body: some View {
    VStack {
      VStack {
        if let id = sample.model.id {
          HStack {
            Text("ID: ")
            Spacer()
            Text("\(id)")
          }
        }
        HStack {
          Text("Patient Name: ")
          Spacer()
          TextField("First and Last Name", text: $patient_name).multilineTextAlignment(.trailing)
        }
        HStack {
          Text("Device ID*:")
          Spacer()
          TextField("Device ID", text: $device_id).modifier(NumericField(field: $device_id)).multilineTextAlignment(.trailing)
        }
        HStack {
          Text("Vial ID: ")
          Spacer()
          TextField("Enter Vial ID", text: $vial_id).modifier(NumericField(field: $vial_id)).multilineTextAlignment(.trailing)
        }
        HStack {
          Text("Container ID: ")
          Spacer()
          TextField("Enter Container ID", text: $container_id).modifier(NumericField(field: $container_id)).multilineTextAlignment(.trailing)
        }
        DatePicker("Test Date: ", selection: $sample.model.test_date)
        if let sample_comments = sample.model.sample_comments {
          Text("Sample Comments: \(sample_comments)")
        }
      }
      if sample.model.id == nil {
        HStack {
          Button("Add Sample") {
            Task {
              await createSample()
            }
          }.buttonStyle(.borderedProminent)
          Spacer()
          Button("Cancel") {
            edit = false
            Task {
              await loadSample()
            }
          }.buttonStyle(.bordered)
        }.padding()
      } else if edit {
        HStack {
          Button("Update") {
            Task {
              await createSample()
            }
          }.buttonStyle(.borderedProminent)
          Spacer()
          Button("Cancel") {
            edit = false
            Task {
              await loadSample()
            }
          }.buttonStyle(.bordered)
        }.padding()
      } else {
        Button("Edit") {
          edit = !edit
        }
      }
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
    }.padding().task {
      await loadSample()
      patient_name = sample.model.patient_name
      device_id = "\(guardEmptyVal(val: sample.model.device_id))"
      vial_id = "\(guardEmptyVal(val: sample.model.vial_id))"
      container_id = "\(guardEmptyVal(val: sample.model.container_id))"
    }.refreshable {
      await loadSample()
    }
  }
}

func guardEmptyVal<T>(val: T?) -> String {
  guard let val = val else {
    return ""
  }
  
  return "\(val)"
}

#Preview {
  @State var isCreateLoading = false
  @State var isLoading = false
  @State var sample = Sample(id: 4,patient_name: "Hello", device_id: 45, test_date: Date())
  
  return SampleView(sample: DynamicResource<Sample>(from: sample, path: "/samples")).environmentObject(AuthResource())
}
