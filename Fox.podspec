Pod::Spec.new do |s|
  s.name         = "Fox"
  s.version      = "1.0.0"
  s.summary      = "A property-based testing library"

  s.description  = <<-DESC
                   DESC

  s.homepage     = "https://github.com/jeffh/Fox"
  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE.md' }


  s.author             = { "Jeff Hui" => "jeff@jeffhui.net" }
  s.ios.deployment_target = "7.0"
  s.osx.deployment_target = "10.10"

  #s.source       = { :git => "https://github.com/jeffh/Fox.git", :tag => "0.0.1" }
  s.source       = { :git => "https://github.com/jeffh/Fox.git", :branch => "master" }

  s.source_files  = "Fox/**/*.{h,m,mm}"
  s.public_header_files = "Fox/Public/**/*.h"

  s.libraries = 'c++'
  s.xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++0x',
    'CLANG_CXX_LIBRARY' => 'libc++',
  }
end
