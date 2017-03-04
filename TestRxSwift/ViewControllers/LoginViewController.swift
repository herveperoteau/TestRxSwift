//
//  ViewController.swift
//  TestRxSwift
//
//  Created by herve.peroteau on 10/02/2017.
//  Copyright © 2017 myfox HPU. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class LoginViewController: UIViewController {
  
  struct Segues {
    static let SignIn = "signInSegue"
  }
  
  var disposeBag = DisposeBag()
  var viewModel: LoginViewModel?
  
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var signInButton: UIButton!
  @IBOutlet weak var signInActivityIndicator: UIActivityIndicatorView!
  
  override func viewDidLoad(){
    super.viewDidLoad()
    setupViewModel()
  }
  
  private func setupViewModel() {    
    viewModel = LoginViewModel(
      input: (
        username: usernameTextField.rx.text.orEmpty.asObservable(),
        password: passwordTextField.rx.text.orEmpty.asObservable(),
        loginTaps: signInButton.rx.tap.asObservable()
      ),
      dependency: (
        API: CloudDefaultAPI.sharedAPI,
        wireframe: DefaultWireframe.sharedInstance
      )
    )
    
    // bind results to
    viewModel?.signinEnabled
      .subscribe(onNext: { [weak self] valid  in
        self?.signInButton.isEnabled = valid
      })
      .disposed(by: disposeBag)
    
    viewModel?.signingIn
      .bindTo(signInActivityIndicator.rx.isAnimating)
      .disposed(by: disposeBag)
    
    viewModel?.signedIn
      .subscribe(onNext: { [weak self] signedIn in
        print("User signed in \(signedIn)")
        if signedIn {
          self?.performSegue(withIdentifier: Segues.SignIn, sender: nil)
        }
      })
      .disposed(by: disposeBag)
  }
  
  @IBAction func unwindToSign(segue: UIStoryboardSegue) {
    usernameTextField.text = ""
    passwordTextField.text = ""
    setupViewModel()
  }
  
}

