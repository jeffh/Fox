Pod::Spec.new do |s|
  s.name         = "Fox"
  s.version      = "1.0.0"
  s.summary      = "A property-based testing library"

  s.description  = <<-DESC
    Why write tests when you can generate them? Fox is a port of Clojure's
    popular test.check.

    Specify your tests in terms of properties your code should hold. Fox's job is
    to generate tests to find a counter-example that your property does not hold.

    Fox will also shrink the counter-example to the smallest possible example
    to make it easier to debug failures.
                   DESC

  s.homepage     = "https://github.com/jeffh/Fox"
  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE.md' }


  s.author             = { "Jeff Hui" => "jeff@jeffhui.net" }
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"

  s.source       = { :git => "https://github.com/jeffh/Fox.git", :tag => "v1.0.0" }

  s.source_files  = "Fox/**/*.{h,m,mm}"
  s.public_header_files = "Fox/Public/**/*.h"

  s.libraries = 'c++'
  s.xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++0x',
    'CLANG_CXX_LIBRARY' => 'libc++',
  }
end
