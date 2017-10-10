//
//  ViewModel.swift
//  Demo
//
//  Created by Listen on 2017/10/11.
//  Copyright © 2017年 非非白. All rights reserved.
//

import Foundation
import RxCommand
import RxSwift

class ViewModel {
    // input
    let phoneNumber = Variable("")
    let captcha = Variable("")

    let disposeBag = DisposeBag()

    // command
    // 倒计时
    lazy var countdownCommand: RxCommand<Void, String> = {
        return RxCommand { _ in
            return Observable<Int>.timer(0, period: 1, scheduler: MainScheduler.instance )
                .take(60) // from 0 - 59
                .map({ (pass) -> Int in
                    59 - pass
                })
                .map({ (remain) -> String in
                    return remain == 0 ? "获取验证码" : "重新获取 \(remain)"
                })
        }
    }()

    // 获取验证码
    lazy var captchaCommand: RxCommand<Void, Void> = {
        let captchaEnabled = Observable<Bool>
            .combineLatest(self.phoneNumber.asObservable(), self.countdownCommand.executing) { phone, executing in
                return phone.characters.count == 11 && !executing
        }
        return RxCommand(enabled:captchaEnabled) {[weak self] _ in
            guard let `self` = self else { return Observable.empty()}
            return self
                .fetchCaptcha(phoneNumber: self.phoneNumber.value)
                .do(onNext: { [weak self] _ in
                        self?.countdownCommand.execute()
                })
        }
    }()

    // 登陆
    lazy var loginCommand: RxCommand<Void, String> = {
        let loginEnabled = Observable<Bool>
            .combineLatest(self.phoneNumber.asObservable(), self.captcha.asObservable()) { $0.characters.count == 11 &&  $1.characters.count == 6 }
        
        return RxCommand(enabled: loginEnabled) { [weak self] _ in
            guard let `self` = self else { return Observable.empty()}
            return self
                .login(phoneNumber: self.phoneNumber.value, captcha: self.captcha.value)
        }
        
    }()
    
    // 模拟登陆
    private func login(phoneNumber: String, captcha: String) -> Observable<String> {
        return Observable<Int>.timer(4, scheduler: MainScheduler.instance)
            .flatMap { _ -> Observable<String> in
                if captcha == "123456" {
                    return Observable.just("success")
                } else {
                    return Observable.error(NSError(domain: "ViewModel", code:0, userInfo: [NSLocalizedDescriptionKey : "错误的验证码!!"]))
                }
            }
    }
    
    // 模拟获取验证码
    private func fetchCaptcha(phoneNumber: String) -> Observable<Void> {
        return Observable<Int>.timer(2, scheduler: MainScheduler.instance)
            .map{ _ in () }
            .ignoreElements()
            .concat(Observable.just(()))
    }
}
