//
//  ContentView.swift
//  papeasy
//
//  Created by Ethan Silver on 2023-11-01.
//

import SwiftUI
import SwiftData

struct ContentView: View {
  @StateObject var auth = AuthResource()
  var body: some View {
    BaseHomeView().environmentObject(auth)
  }
}

#Preview {
  ContentView()
}
