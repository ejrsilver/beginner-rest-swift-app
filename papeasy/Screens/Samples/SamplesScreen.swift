//
//  Samples.swift
//  papeasy
//
//  Created by Ethan Silver on 2023-11-02.
//

import Foundation
import SwiftUI
import SwiftData
import Combine

struct SamplesScreen: View {
  @ObservedObject var auth: Authentication
  @ObservedObject var samples: Samples
  @State private var isLoading = false
  @State private var isCreateLoading = false
  @State private var showCreateSample = false
  
  @MainActor func loadSamples() async {
    guard let token = auth.auth else {
      return
    }
    isLoading = true
    do {
      try await samples.list(auth: token)
    } catch {
      print("\(error)")
    }
    isLoading = false
  }

  var body: some View {
    VStack {
      if let samples = samples.samples {
        if samples.isEmpty {
          Text("No samples yet.")
        } else {
          samplesList(samples: samples)
          Spacer()
        }
      } else if isLoading {
        ProgressView()
      }
    }
    .task {
      await loadSamples()
    }
    .refreshable {
      await loadSamples()
    }
    .popover(isPresented: $showCreateSample) {
      CreateSamplePopup(
        auth: auth,
        samples: self.samples,
        show: $showCreateSample,
        isParentLoading: $isLoading,
        onLoad: loadSamples
      )
    }
  }
  
  func samplesList(samples: [Sample]) -> some View {
    NavigationSplitView {
      VStack {
        List (samples) { sample in
          NavigationLink {
            SampleView(sample: sample)
          } label: {
            Text(sample.test_date, format: Date.FormatStyle(date: .numeric, time: .standard))
          }
        }.toolbar {
          ToolbarItem(placement: .bottomBar) {
            Button("New Sample") {
              showCreateSample = true
            }.buttonStyle(.borderedProminent)
          }
        }
        .listStyle(.plain)
        .listRowInsets(.none)
        .navigationTitle("Samples")
        .navigationBarTitleDisplayMode(.inline)
      }
    } detail: {
      Text("Please Select a Sample")
    }
  }
}

#Preview("Standard", traits: .defaultLayout) {
  @StateObject var samples = Samples(samples: [Sample(id: 5, patient_name: "Test", device_id: 4, sample_status: Status.Positive, test_date: Date())])
  
  return SamplesScreen(
    auth: Authentication(),
    samples: samples
  )
}

#Preview("No Samples", traits: .defaultLayout) {
  return SamplesScreen(
    auth: Authentication(test: true),
    samples: Samples(samples: [Sample]())
  )
}

#Preview("No Samples or Auth", traits: .defaultLayout) {
  return SamplesScreen(
    auth: Authentication(test: true),
    samples: Samples()
  )
}
