.. highlight:: objective-c

Installation
============

Fox can be installed in multiple ways. If you don't have a preference, see manual.

Manually (Git Submodule)
------------------------

Add Fox as a submodule to your project::

    git submodule add https://github.com/jeffh/Fox.git Externals/Fox

Add ``Fox.xcodeproj`` to your Xcode project. Then link Fox-iOS or Fox-OSX to
your test target.

CocoaPods
---------

Add to your Podfile for you test target::

    pod 'Fox', :git => 'https://github.com/jeffh/Fox'

And then ``pod install``.


Carthage
--------

TODO

