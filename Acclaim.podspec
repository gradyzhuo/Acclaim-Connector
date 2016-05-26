Pod::Spec.new do |spec|
spec.name         = "Acclaim"
spec.version      = "0.1.2"
spec.summary      = "整合式 Server API 呼叫的好幫手。"
spec.description  = <<-DESC
Acclaim 是[整合式 Server API 呼叫的好幫手]。
DESC
spec.homepage     = "https://github.com/gradyzhuo/Acclaim.git"
spec.license      = { :type => 'MIT', :file => 'LICENSE.txt' }
spec.author       = { "Grady Zhuo" => "gradyzhuo@gmail.com" }
spec.social_media_url = "https://about.me/gradyzhuo"
spec.source       = { :git => "https://github.com/gradyzhuo/Acclaim.git", :tag => spec.version.to_s }
spec.platform     = :ios, '9.0'
spec.requires_arc = true
spec.source_files = 'AcclaimSwift/Acclaim/Classes/**/*.swift'
spec.frameworks   = 'Foundation'
spec.compiler_flags = '-D DEBUG'
end
