//
//  Home.swift
//  papeasy
//
//  Created by Ethan Silver on 2023-11-02.
//

import Foundation
import SwiftUI
import SwiftData

struct Home: View {
  @ObservedObject var auth: Authentication
  @ObservedObject var account: Accounts
  @ObservedObject var samples: Samples
  @State private var isLoading: Bool = false
  @State private var showLogin: Bool = false
  @State private var showSignup: Bool = false

  @MainActor private func onLoad() async {
    guard let token = auth.auth else {
      return
    }
    isLoading = true
    do {
      try await account.me(auth: token)
    } catch {
      print("\(error)")
    }
    isLoading = false
  }

  var body: some View {
    VStack {
      if auth.auth != nil, let me = account.me {
        signedIn(me: me)
      } else if isLoading {
        ProgressView()
      } else {
        welcome
      }
    }.task {
      await onLoad()
    }.refreshable {
      await onLoad()
    }.popover(isPresented: $showLogin) {
      Login(
        auth: auth,
        show: $showLogin,
        isParentLoading: $isLoading,
        onLoad: onLoad
      )
    }
    .popover(isPresented: $showSignup) {
      Signup(
        auth: auth,
        account: account,
        show: $showSignup,
        showLogin: $showLogin,
        isParentLoading: $isLoading
      )
    }
  }
  
  func signedIn(me: User) -> some View {
    return VStack {
      HStack {
        Text("Welcome, \(me.first_name) \(me.last_name)!")
        Spacer()
        Button(action: auth.logout, label: {
          Text("Logout")
        })
      }
      Spacer()
      NavigationLink("View or Update My Samples") {
        SamplesScreen(auth: auth, samples: samples)
      }.navigationTitle("Home").buttonStyle(.borderedProminent)
    }
  }
  
  var welcome: some View {
    VStack {
      Text("Login or sign up to start using the PapEasy platform.")
        .multilineTextAlignment(.center)
      Spacer()
      HStack {
        Button("Login") {
          showLogin = true
        }.buttonStyle(.bordered)
        Spacer()
        Button("Sign Up") {
          showSignup = true
        }.buttonStyle(.borderedProminent)
      }.padding()
    }
    .navigationTitle("Welcome to PapEasy")
  }
}

#Preview("Home") {
  Home(
    auth: Authentication(auth: nil),
    account: Accounts(),
    samples: Samples()
  )
}
