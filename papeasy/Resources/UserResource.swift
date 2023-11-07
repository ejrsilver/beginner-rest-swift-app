//
//  AccountsResource.swift
//  papeasy
//
//  Created by Ethan Silver on 2023-11-04.
//

import Foundation

class UserResource: DynamicResource<User> {
  init() {
    super.init(path: "/accounts/me")
  }
}
