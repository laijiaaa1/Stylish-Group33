//
//  LoginViewController.swift
//  STYLiSH
//
//  Created by Red Wang on 2023/11/4.
//  Copyright © 2023 AppWorks School. All rights reserved.
//

import UIKit

class LogInViewController: STBaseViewController {
    
    private let userProvider = UserProvider(httpClient: HTTPClient())

    // MARK: - Subviews
    private let instructionLabel: UILabel = {
        let instructionLabel = UILabel()
        instructionLabel.font = .medium(size: 18)
        instructionLabel.textColor = .B2
        instructionLabel.text = "請先登入會員"
        return instructionLabel
    }()
    private let accountLabel: UILabel = {
        let accountLabel = UILabel()
        accountLabel.font = .regular(size: 16)
        accountLabel.textColor = .B2
        accountLabel.text = "帳號"
        return accountLabel
    }()
    private let passwordLabel: UILabel = {
        let passwordLabel = UILabel()
        passwordLabel.font = .regular(size: 16)
        passwordLabel.textColor = .B2
        passwordLabel.text = "密碼"
        return passwordLabel
    }()
    private let accountTextField: UITextField = {
        let accountTextField = UITextField()
        accountTextField.placeholder = "輸入帳號"
        accountTextField.textColor = .B2
        accountTextField.font = .regular(size: 18)
        accountTextField.backgroundColor = .B5
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 48))
        accountTextField.leftView = paddingView
        accountTextField.leftViewMode = .always
        return accountTextField
    }()
    private let passwordTextField: UITextField = {
        let passwordTextField = UITextField()
        passwordTextField.placeholder = "輸入密碼"
        passwordTextField.textColor = .B2
        passwordTextField.font = .regular(size: 18)
        passwordTextField.backgroundColor = .B5
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 48))
        passwordTextField.leftView = paddingView
        passwordTextField.leftViewMode = .always
        return passwordTextField
    }()
    private let dismissButton: UIButton = {
        let dismissButton = UIButton()
        dismissButton.setImage(UIImage(named: "Icons_24px_Close"), for: .normal)
        return dismissButton
    }()
    private let seperatorView: UIView = {
        let seperatorView = UIView()
        seperatorView.backgroundColor = .G1
        return seperatorView
    }()
    private let logInButton: UIButton = {
        let logInButton = UIButton()
        logInButton.backgroundColor = .B2
        logInButton.setTitle("登入", for: .normal)
        logInButton.setTitleColor(.white, for: .normal)
        logInButton.titleLabel?.font = .regular(size: 16)
        return logInButton
    }()
    
    // MARK: - View Load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpLayouts()
        setUpActions()
    }
    private func setUpLayouts() {
        view.addSubview(instructionLabel)
        view.addSubview(accountLabel)
        view.addSubview(passwordLabel)
        view.addSubview(accountTextField)
        view.addSubview(passwordTextField)
        view.addSubview(seperatorView)
        view.addSubview(dismissButton)
        view.addSubview(logInButton)
        
        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            instructionLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            accountLabel.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 28),
            accountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            accountTextField.topAnchor.constraint(equalTo: accountLabel.bottomAnchor, constant: 8),
            accountTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            accountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            accountTextField.heightAnchor.constraint(equalToConstant: 48),
            
            passwordLabel.topAnchor.constraint(equalTo: accountTextField.bottomAnchor, constant: 16),
            passwordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 8),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            passwordTextField.heightAnchor.constraint(equalToConstant: 48),
            
            dismissButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            dismissButton.heightAnchor.constraint(equalToConstant: 24),
            dismissButton.widthAnchor.constraint(equalToConstant: 24),
           
            seperatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            seperatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            seperatorView.heightAnchor.constraint(equalToConstant: 1),
            seperatorView.bottomAnchor.constraint(equalTo: logInButton.topAnchor, constant: -16),
            
            logInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            logInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logInButton.heightAnchor.constraint(equalToConstant: 48),
            logInButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    private func setUpActions() {
        dismissButton.addTarget(self, action: #selector(dismissLogInViewPressed), for: .touchUpInside)
        logInButton.addTarget(self, action: #selector(nativeLoginTapped), for: .touchUpInside)
    }
    
    // MARK: - Methods
    @objc func dismissLogInViewPressed(sender: UIButton!) {
        dismiss(animated: true)
    }
    @objc func nativeLoginTapped(sender: UIButton!) {
        guard let accountText = accountTextField.text,
              accountText != "" ,
              let passwordText = passwordTextField.text,
              passwordText != "" else {
            LKProgressHUD.showFailure(text: "請輸入完整資訊")
            return
        }
        self.dismiss(animated: true)
        LKProgressHUD.show()
        
        userProvider.signInToStylish(
            email: accountText,
            password: passwordText, completion: { [weak self] result in
            LKProgressHUD.dismiss()
                
            switch result {
            case .success:
                LKProgressHUD.showSuccess(text: "STYLiSH 登入成功")
            case .failure:
                LKProgressHUD.showSuccess(text: "STYLiSH 登入失敗!")
            }
            DispatchQueue.main.async {
                self?.presentingViewController?.dismiss(animated: false, completion: nil)
            }
        })
        
    }
  
    
    
}

