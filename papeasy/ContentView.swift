//
//  ContentView.swift
//  papeasy
//
//  Created by Ethan Silver on 2023-11-01.
//

import SwiftUI
import SwiftData

struct ContentView: View {
  @StateObject var auth = Authentication()
  @StateObject var account = Accounts()
  @StateObject var samples = Samples()
  var body: some View {
    NavigationStack {
      Home(auth: auth, account: account, samples: samples)
    }.padding()
  }
}

#Preview {
  ContentView()
}
