//
//  LoginViewModel.swift
//  TestRxSwift
//
//  Created by Hervé PEROTEAU on 12/02/2017.
//  Copyright © 2017 myfox HPU. All rights reserved.
//

import UIKit
import RxSwift

// MARK: - ViewModel

class LoginViewModel {
  
  deinit {
    NSLog("LoginViewModel deinit")
  }
  
  let validatedUsername: Observable<Bool>
  let validatedPassword: Observable<Bool>

  // Is signin button enabled
  let signinEnabled: Observable<Bool>
  
  // Has user signed in
  let signedIn: Observable<Bool>
  
  // Is signing process in progress
  let signingIn: Observable<Bool>
  
  init(input: (
    username: Observable<String>,
    password: Observable<String>,
    loginTaps: Observable<Void>
    ),
       dependency: (
    API: CloudAPI,
    wireframe: Wireframe
    )
    ) {
    
    let API = dependency.API
    let wireframe = dependency.wireframe
    
    /**
     Notice how no subscribe call is being made.
     Everything is just a definition.
     
     Pure transformation of input sequences to output sequences.
     */
    
    validatedUsername = input.username
      .map { username in
        return username.characters.count > 0
      }
      .shareReplay(1)
    
    validatedPassword = input.password
      .map { password in
        return password.characters.count > 0
      }
      .shareReplay(1)
    
    let signingIn = ActivityIndicator()
    self.signingIn = signingIn.asObservable()
    
    let usernameAndPassword = Observable.combineLatest(input.username, input.password) { ($0, $1) }
    
    //signedIn = Variable(false).asObservable().trackActivity(signingIn)
    
    signedIn = input.loginTaps.withLatestFrom(usernameAndPassword)
      .flatMapLatest { (username, password) in
        return API.signin(username: username, password: password)
          .observeOn(MainScheduler.instance)
          .catchErrorJustReturn(false)
          .trackActivity(signingIn)
      }
      .flatMapLatest { loggedIn -> Observable<Bool> in
        let message = loggedIn ? "Mock: Signed in success." : "Mock: Sign in failed"
        return wireframe.promptFor(message, cancelAction: "OK", actions: [])
          // propagate original value
          .map { _ in
            loggedIn
        }
      }
      .shareReplay(1)
    
    signinEnabled = Observable.combineLatest(
      validatedUsername,
      validatedPassword,
      signingIn.asObservable()) {
        print("signInEnabled evaluate ...")
        return $0 && $1 && !$2 }
      .distinctUntilChanged()
      .shareReplay(1)
  }
}
