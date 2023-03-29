//
//  LoginViewController.swift
//  BeReal
//
//  Created by Vaibhav Rajani on 3/21/23.
//

import UIKit
import ParseSwift

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func onLoginTapped(_ sender: Any) {
        
        guard let username = usernameField.text,
              let password = passwordField.text,
              !username.isEmpty,
              !password.isEmpty else {
            showMissingFieldsAlert()
            return
        }
        
        User.login(username: username, password: password) { [weak self] result in
                    
            guard let self = self else { return }
                    
            switch result {
            case .success(let user):
                print("✅ Successfully logged in as user: \(user)")
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name("login"), object: nil)
                }
                
            case .failure(let error):
                self.showAlert(description: error.localizedDescription)
            }
        }
    }
    
    private func showAlert(description: String?) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Unable to Log in", message: description ?? "Unknown error", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(action)
            self.present(alertController, animated: true)
        }
    }

    private func showMissingFieldsAlert() {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Opps...", message: "We need all fields filled out in order to log you in.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(action)
            self.present(alertController, animated: true)
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

}
