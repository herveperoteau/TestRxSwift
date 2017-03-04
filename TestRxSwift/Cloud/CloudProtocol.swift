//
//  CloudProtocol.swift
//  TestRxSwift
//
//  Created by Hervé PEROTEAU on 12/02/2017.
//  Copyright © 2017 myfox HPU. All rights reserved.
//

import Foundation
import RxSwift

enum ValidationResult {
  case ok(message: String)
  case empty
  case validating
  case failed(message: String)
}

protocol CloudAPI {
  func signin(username: String, password: String) -> Observable<Bool>
}

