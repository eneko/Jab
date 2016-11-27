Pod::Spec.new do |s|

  s.name         = "Jab"
  s.version      = "0.1.0"
  s.summary      = "Jab likes synchronous HTTP JSON requests."
  s.homepage     = "http://github.com/eneko/Jab"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Eneko Alonso" => "eneko.alonso@gmail.com" }
  s.social_media_url = "http://twitter.com/eneko"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
#  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"

  s.source = { :git => "https://github.com/eneko/Jab.git", :tag => s.version }
  s.source_files  = "Sources/*.swift"

end
