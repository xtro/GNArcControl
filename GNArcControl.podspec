Pod::Spec.new do |s|
  s.name                  = "GNArcControl"
  s.version               = "0.1"
  s.summary               = "GNArcControl"
  s.description           = <<-DESC
                            GNArcControl provides:
                            DESC
  s.homepage              = "https://www.linkedin.com/in/reformer"
  s.author                = { "Gabor Nagy" => "gabor.nagy.0814@gmail.com" }
  s.license               = 'MIT'
  s.source                = { :git => "https://reformer_ssh@bitbucket.org/calstore/calstorekit.git", :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.requires_arc          = true
  s.source_files          = "Source/**/*.{h,swift}"
  # s.resources             = "SDK/Resources/**/*.{png,storyboard,strings,xib}","SDK/Resources/Resources.xcassets/**/*.{png,jpg}", "SDK/**/*.{png,storyboard,strings,xib}"
  s.weak_frameworks       = "UIKit"
end
