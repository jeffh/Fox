.. highlight:: objective-c

Installation
============

Fox can be installed in multiple ways. If you don't have a preference, install
via git submodule.

Fox honors `semantic versioning` as humanly possible. If you're unsure if a
given update is backwards incompatible with your usage. Check out the
`releases`_.

.. _semantic versioning: http://semver.org
.. _releases: https://github.com/jeffh/Fox/releases

Manually (Git Submodule)
------------------------

Add Fox as a submodule to your project::

    $ git submodule add https://github.com/jeffh/Fox.git Externals/Fox

If you don't want bleeding edge, check out the particular tag of the version::

    $ cd Externals/Fox
    $ git checkout v1.0.1

Add ``Fox.xcodeproj`` to your Xcode project (not ``Fox.xcworkspace``). Then
link Fox-iOS or Fox-OSX to your test target.

And you're all set up! Dive right in by following the :doc:`tutorial
</tutorial>`.

CocoaPods
---------

Add to your Podfile for you test target to have the latest stable version of
Fox::

    pod 'Fox', '~>1.0.1'

And then ``pod install``.

And you're all set up! Dive right in by following the :doc:`tutorial
</tutorial>`.

Carthage
--------

TODO

