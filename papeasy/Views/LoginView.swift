//
//  LoginScreen.swift
//  papeasy
//
//  Created by Ethan Silver on 2023-11-02.
//

import Foundation
import SwiftUI

struct LoginView: View {
  @Binding var show: Bool

  @EnvironmentObject var auth: AuthResource
  @State private var email: String = ""
  @State private var password: String = ""
  @State private var isLoading: Bool = false
  @State var resp: String?

  private func onLogin() async {
    isLoading = true
    do {
      try await auth.login(
        email: self.email,
        password: self.password
      )
      resp = "Login Successul!"
      show = false
    } catch ResourceError.Failure(let message) {
      resp = "\(message)"
    } catch {
      print("\(error)")
    }
    isLoading = false
  }
  
  var body: some View {
    ZStack {
      if isLoading {
        ProgressView()
      } else if let success = resp, auth.model != nil {
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
  
  return LoginView(
    show: $isCreateLoading, resp: "Success!"
  )
}

#Preview("Default") {
  @State var isCreateLoading = false
  @State var isLoading = false
  
  return LoginView(
    show: $isCreateLoading
  )
}

#Preview("Not Authenticated") {
  @State var isCreateLoading = false
  @State var isLoading = false
  
  return LoginView(
    show: $isCreateLoading, resp: "Invalid parameter(s): device_id"
  )
}
