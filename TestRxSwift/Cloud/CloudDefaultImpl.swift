//
//  CloudDefaultImpl.swift
//  TestRxSwift
//
//  Created by Hervé PEROTEAU on 12/02/2017.
//  Copyright © 2017 myfox HPU. All rights reserved.
//

import Foundation
import RxSwift

class CloudDefaultAPI : CloudAPI {

  static let sharedAPI = CloudDefaultAPI(
    URLSession: Foundation.URLSession.shared
  )
  
  let URLSession: Foundation.URLSession
  
  init(URLSession: Foundation.URLSession) {
    self.URLSession = URLSession
  }
  
  func signin(username: String, password: String) -> Observable<Bool> {
    // Just fake by check Github username
    let usernameClean = username.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    let url = URL(string: "https://github.com/\(usernameClean!)")!
    let request = URLRequest(url: url)
    return URLSession.rx.response(request: request)
      .map { (response, _) in
        return response.statusCode == 200
      }
      .catchErrorJustReturn(false)
  }
  
}
