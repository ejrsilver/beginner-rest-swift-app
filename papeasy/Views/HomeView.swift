//
//  Home.swift
//  papeasy
//
//  Created by Ethan Silver on 2023-11-02.
//

import Foundation
import SwiftUI

struct BaseHomeView: View {
  @EnvironmentObject var auth: AuthResource
  @StateObject var user = DynamicResource<User?>(from: nil, path: "/accounts/me")
  @State private var isLoading: Bool = false
  @State var showLogin: Bool = false
  @State var showSignup: Bool = false
  @State var showSamples: Bool = false

  func loadUser() async {
    guard let auth = auth.model else { return }
    user.setup(auth: auth)
    isLoading = true
    do {
      try await user.retrieve()
    } catch {
      print("\(error)")
    }
    isLoading = false
  }
  
  var body: some View {
    VStack {
      if auth.model != nil, user.model != nil {
        AuthorizedHomeView().environmentObject(user)
      } else if isLoading {
        ProgressView()
      } else {
        UnauthorizedHomeView(showLogin: $showLogin, showSignup: $showSignup)
      }
    }.padding()
      .task {
        await loadUser()
      }.refreshable {
        await loadUser()
      }.popover(isPresented: $showLogin) {
        LoginView(show: $showLogin).environmentObject(auth)
      }
      .popover(isPresented: $showSignup) {
        RegistrationView(show: $showSignup, showLogin: $showLogin)
      }
  }
}

struct AuthorizedHomeView: View {
  @EnvironmentObject var user: DynamicResource<User?>
  @EnvironmentObject var auth: AuthResource
  var body: some View{
    NavigationStack {
      VStack {
        NavigationLink("View or Update My Samples") {
          SamplesView().environmentObject(auth)
        }
      }.navigationBarTitleDisplayMode(.inline).toolbar {
        ToolbarTitleMenu {
          Button(action: auth.logout, label: {
            Text("Logout")
          })
        }
        ToolbarItem(placement: .principal) {
          Text("Welcome, \(user.model!.first_name!) \(user.model!.last_name!)!").font(.headline)
        }
        
      }.navigationTitle("Home")
    }
  }
}

struct UnauthorizedHomeView: View {
  @Binding var showLogin: Bool
  @Binding var showSignup: Bool
  
  var body: some View {
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
  BaseHomeView().environmentObject(AuthResource())
}
