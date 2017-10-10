//
//  ViewController.swift
//  Demo
//
//  Created by Listen on 2017/10/11.
//  Copyright © 2017年 非非白. All rights reserved.
//

import UIKit
import RxCommand
import RxSwift

class ViewController: UIViewController {

    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var captchaTextField: UITextField!
    @IBOutlet weak var captchaButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    let bag = DisposeBag()
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }

    func setupBindings() {
        
        // ----- input ----
        // 输入手机号码
        phoneNumberTextField
            .rx
            .text
            .orEmpty
            .bind(to: viewModel.phoneNumber)
            .disposed(by: bag)
        
        // 输入验证码
        captchaTextField
            .rx
            .text
            .orEmpty
            .bind(to: viewModel.captcha)
            .disposed(by: bag)
        
        // 点击获取验证码按钮
        captchaButton
            .rx
            .command
            .bind(to: viewModel.captchaCommand)
            .disposed(by: bag)
        
        // 点击登陆按钮
        loginButton
            .rx
            .command
            .bind(to: viewModel.loginCommand)
            .disposed(by: bag)
        
        // ----- output ----
        // 登陆成功
        viewModel
            .loginCommand
            .switchLatest()
            .bind { [weak self] _ in
                guard let `self` = self else { return }
                ProgressHUD.showMessage("登陆成功", addTo: self.view)
            }
            .disposed(by: bag)
        
        // 获取验证码成功
        viewModel.captchaCommand
            .switchLatest()
            .bind { [weak self] _ in
                guard let `self` = self else { return }
                ProgressHUD.showMessage("请求成功，你的验证码是 123456", addTo: self.view)
            }
            .disposed(by: bag)
        
        // 倒计时
        viewModel.countdownCommand
            .switchLatest()
            .bind(to: captchaButton.rx.title())
            .disposed(by: bag)
        
    
        // 错误处理
        Observable.merge(viewModel.captchaCommand.errors, viewModel.loginCommand.errors)
            .bind { [weak self] error in
                guard let `self` = self else { return }
                ProgressHUD.showError(error.localizedDescription, addTo: self.view)
            }
            .disposed(by: bag)
        
        // loading
        Observable.merge(viewModel.captchaCommand.executing, viewModel.loginCommand.executing)
            .bind { [weak self] executing in
                guard let `self` = self else { return }
                executing ? ProgressHUD.showLoading(self.view) : ProgressHUD.hideLoading(self.view)
            }
         .disposed(by: bag)

    }
}

