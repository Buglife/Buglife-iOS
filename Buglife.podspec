Pod::Spec.new do |s|
  s.name                  = "Buglife"
  s.version               = "2.0.0"
  s.summary               = "Awesome bug reporting 😎"
  s.description           = "Report bugs, annotate screenshots, and collect logs from within your iOS app!"
  s.homepage              = "https://www.buglife.com"
  s.license               = { "type" => "Apache", :file => 'LICENSE' }
  s.author                = { "Buglife" => "support@buglife.com" }
  s.source                = { "git" => "https://github.com/Buglife/Buglife-iOS.git", :tag => s.version.to_s }
  s.platform              = :ios, '9.0'
  s.source_files          = "Source/**/*"
  s.public_header_files   = "Source/*.{h}"
end
