# RxCommand-Swift

A command is an Observable triggered in response to some action, typicallyUI-related.

It manage the extra states, such as loading, enabled, errors for you.


## Code like this

ViewModel

```swift
// 登陆
lazy var loginCommand: RxCommand<Void, String> = {
    let loginEnabled = Observable<Bool>
        .combineLatest(self.phoneNumber.asObservable(), self.captcha.asObservable()) 
        	{ $0.characters.count == 11 &&  $1.characters.count == 6 }
    
    return RxCommand(enabled: loginEnabled) { [weak self] _ in
        guard let `self` = self else { return Observable.empty()}
        return self
            .login(phoneNumber: self.phoneNumber.value, captcha: self.captcha.value)
    }
}()
```

Controller

```swift
func setupBindings() {
	
	// ----- input ----
	// press login button
	loginButton
	    .rx
	    .command
	    .bind(to: viewModel.loginCommand)
	    .disposed(by: bag)
  
	// ----- output ----
	// handle login success
	viewModel
		.loginCommand
		.switchLatest()
		.bind { [weak self] _ in
		    guard let `self` = self else { return }
		    ProgressHUD.showMessage("登陆成功", addTo: self.view)
		}
		.disposed(by: bag)
		
	// error handling
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
```


## Installation

```
pod 'RxCommand', :git => "git@github.com:listenzz/RxCommand-Swift.git"
```

## Android

[Android-RxCommand](https://github.com/listenzz/RxCommand)