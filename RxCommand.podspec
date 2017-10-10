Pod::Spec.new do |s|
s.name         = "RxCommand"
s.version      = "0.0.1"
s.summary      = "Abstracts command to be performed in RxSwift."
s.description  = <<-DESC
A command is an observable triggered in response to some action, typically UI-related.
DESC
s.homepage     = "https://github.com/listenzz/RxCommand-Swift"
s.license      = { :type => "MIT", :file => "LICENSE" }
s.author             = { "Listen" => "https://listenzz.github.io/" }

s.ios.deployment_target = '8.0'
s.osx.deployment_target = '10.10'
s.watchos.deployment_target = '2.0'
s.tvos.deployment_target = '9.0'

s.source       = { :git => "git@github.com:listenzz/RxCommand-Swift.git", :tag => s.version.to_s }
# s.source       = { :path => "./" }
s.source_files  = "RxCommand/RxCommand/**/*.{swift}"

s.frameworks  = "Foundation"
s.dependency "RxSwift", "~> 3.0"
s.dependency "RxCocoa", "~> 3.0"

end
