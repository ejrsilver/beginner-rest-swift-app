//
//  Samples.swift
//
//  Created by Ethan Silver on 2023-11-02.
//

import Foundation
import SwiftUI
import SwiftData
import Combine

struct SamplesView: View {
  @EnvironmentObject var auth: AuthResource
  @ObservedObject var samples = DynamicResource<[Sample]?>(from: nil, path: "/samples")
  
  @State private var showCreateSample = false
  @State var resp: String?
  
  func loadSamples() async {
    do {
      try await samples.retrieve()
      resp = nil
    } catch {
      resp = "\(error)"
      print("\(error)")
    }
  }
  
  var body: some View {
    VStack {
      if let samples = samples.model {
        NavigationSplitView {
          VStack {
            List (samples) { sample in
              NavigationLink {
                if let id = sample.id {
                  SampleView(auth: _auth, sample: DynamicResource<Sample>(from: sample, path: "/samples/\(id)")).environmentObject(self.samples)
                }
              } label: {
                Text(sample.test_date, format: Date.FormatStyle(date: .numeric, time: .standard))
              }
            }.toolbar {
              ToolbarItem(placement: .bottomBar) {
                NavigationLink {
                  SampleView(auth: _auth, sample: DynamicResource<Sample>(from: Sample(), path: "/samples")).environmentObject(self.samples)
                } label: {
                  Image(systemName: "plus")
                    .resizable()
                    .padding(6)
                    .frame(width: 24, height: 24)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .foregroundColor(.white)
                }.buttonStyle(.borderedProminent)
              }
            }
            .listStyle(.plain)
            .listRowInsets(.none)
            .navigationTitle("Samples")
            .navigationBarTitleDisplayMode(.inline)
            
            //NavigationLink(p: $showCreateSample, destination: CreateSampleView(show: $showCreateSample)
          }
        } detail: {
          Text("Please Select a Sample")
        }
      } else if let resp = resp {
        Text(resp)
      } else {
        ProgressView()
      }
    }
    .task {
      guard let auth = auth.model else { return }
      samples.setup(auth: auth)
      await loadSamples()
    }
    .refreshable {
      await loadSamples()
    }
  }
}


#Preview("Standard", traits: .defaultLayout) {  
  return SamplesView(
    samples: DynamicResource<[Sample]?>(from: nil, path: "/samples")
  ).environmentObject(AuthResource())
}

#Preview("No Samples", traits: .defaultLayout) {
  SamplesView(
    samples: DynamicResource<[Sample]?>(from: nil, path: "/samples")
  ).environmentObject(AuthResource())
}

#Preview("No Samples or Auth", traits: .defaultLayout) {
  return SamplesView(
    samples: DynamicResource<[Sample]?>(from: nil, path: "/samples")
  ).environmentObject(AuthResource())
}
