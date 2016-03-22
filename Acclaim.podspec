Pod::Spec.new do |s|
s.name         = "Acclaim"
s.version      = "0.1.1"
s.summary      = "整合式 Server API 呼叫的好幫手。"
s.description  = <<-DESC
Acclaim 是[整合式 Server API 呼叫的好幫手]。
DESC
s.homepage     = "https://github.com/gradyzhuo/Acclaim.git"
s.license      = { :type => 'MIT', :file => 'LICENSE.txt' }
s.author       = { "Grady Zhuo" => "gradyzhuo@gmail.com" }
s.social_media_url = "https://about.me/gradyzhuo"
s.source       = { :git => "https://github.com/gradyzhuo/Acclaim.git", :tag => s.version.to_s }
s.platform     = :ios, '9.0'
s.requires_arc = true
s.source_files = 'AcclaimSwift/Acclaim/Classes/**/*.swift'
s.frameworks   = 'Foundation'
end
