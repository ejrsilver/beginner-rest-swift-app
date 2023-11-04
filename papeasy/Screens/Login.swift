//
//  LoginScreen.swift
//  papeasy
//
//  Created by Ethan Silver on 2023-11-02.
//

import Foundation
import SwiftUI

struct Login: View {
  @ObservedObject var auth: Authentication
  @State private var email: String = ""
  @State private var password: String = ""
  @State private var isLoading: Bool = false
  @State var resp: String?
  
  @Binding var show: Bool
  @Binding var isParentLoading: Bool
  var onLoad: () async -> Void

  private func onLogin() async {
    isLoading = true
    do {
      try await auth.login(
        email: self.email,
        password: self.password,
        rememberme: true
      )
      resp = "Login Successul!"
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
      if isLoading {
        ProgressView()
      } else if let success = resp, auth.auth != nil {
        Text(success)
      } else {
        VStack {
          Spacer()
          Text("Login")
          TextField("Email Address", text: $email)
          SecureField("Password", text: $password)
          HStack {
            Button("Sign In") {
              Task {
                await onLogin()
              }
            }.buttonStyle(.borderedProminent)
            Spacer()
            Button("Cancel") {
              show = false
            }.buttonStyle(.bordered)
          }.padding()
          Spacer()
          if let error = self.resp {
            Text(error);
          }
        }.padding(.all, 30.0)
      }
    }
  }
}

#Preview("Success") {
  @State var isCreateLoading = false
  @State var isLoading = false
  
  return Login(
    auth: Authentication(),
    resp: "Success!",
    show: $isCreateLoading,
    isParentLoading: $isLoading,
    onLoad: SamplesScreen(auth: Authentication(), samples: Samples()).loadSamples
  )
}

#Preview("Default") {
  @State var isCreateLoading = false
  @State var isLoading = false
  
  return Login(
    auth: Authentication(test: false),
    show: $isCreateLoading,
    isParentLoading: $isLoading,
    onLoad: SamplesScreen(auth: Authentication(), samples: Samples()).loadSamples
  )
}

#Preview("Not Authenticated") {
  @State var isCreateLoading = false
  @State var isLoading = false
  
  return Login(
    auth: Authentication(test: false),
    resp: "Invalid parameter(s): device_id",
    show: $isCreateLoading,
    isParentLoading: $isLoading,
    onLoad: SamplesScreen(auth: Authentication(), samples: Samples()).loadSamples
  )
}
