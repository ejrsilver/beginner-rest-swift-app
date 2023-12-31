//
//  Signup.swift
//
//  Created by Ethan Silver on 2023-11-02.
//

import Foundation
import SwiftUI

struct RegistrationView: View {
  @Binding var show: Bool
  @Binding var showLogin: Bool
  
  @ObservedObject var account = StaticResource<UserCredentials, User?>(from: nil, path: "/accounts")
  @State private var email: String = ""
  @State private var first_name: String = ""
  @State private var last_name: String = ""
  @State private var password: String = ""
  @State private var repassword: String = ""
  @State private var resp: String?
  @State private var isLoading = false

  private func onSignup() async {
    if password != repassword {
      resp = "Passwords do not match."
    } else {
      isLoading = true
      do {
        try await account.send(forItem: UserCredentials(first_name: first_name, last_name: last_name, email: email, locale: nil, password: password))
        resp = "Signup Successful! You can now log in."
        show = false
        showLogin = true
      } catch ResourceError.Failure(let message) {
        resp = "\(message)"
      } catch {
        print("\(error)")
      }
      isLoading = false
    }
  }

  
  var body: some View {
    ZStack {
      if isLoading {
        ProgressView()
      } else {
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
        VStack {
          Text("Sign Up")
          Spacer()
          TextField("Email Address", text: $email)
          TextField("First Name", text: $first_name)
          TextField("Last Name", text: $last_name)
          SecureField("Password", text: $password)
          SecureField("Re-Enter Password", text: $repassword)
          HStack {
            Button("Register") {
              Task {
                await onSignup()
              }
            }.buttonStyle(.borderedProminent)
            Spacer()
            Button("Cancel") {
              show = false
            }.buttonStyle(.bordered)
          }.padding()
        }.padding(.all, 30.0)
      }
    }
  }
}
