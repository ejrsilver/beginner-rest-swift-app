//
//  Errors.swift
//
//  Created by Ethan Silver on 2023-11-04.
//

import Foundation

enum ResourceError: Error {
  case ResponseDecodingError(DecodingError)
  case URLError
  case ResponseError
  case ModelError
  case Failure(message: String)
}

enum AuthError: Error {
  case TokenSaveFailure
}

struct ErrorResponse: Codable {
  let code: String
  let message: String
}
