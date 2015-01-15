.. highlight:: objective-c

Installing the Foxling Compiler
===============================

Foxling is a custom compiler built on top of `LLVM`_ and `Clang`_ to provide
implicit cooperative scheduling. It is used in conjunction with :doc:`Fox's
Cooperative Thread Scheduler <scheduler>` to make parallel code more
deterministic.

.. _LLVM: http://llvm.org
.. _Clang: http://clang.llvm.org

Alcatraz
--------

.. If you have `Alcatraz`_, you can install Foxling (Not really, it's a TODO).

Currently, Foxling must be compiled from source or downloaded as a pre-built
binary. See issue.

.. _Alcatraz: http://alcatraz.io

Installing a Prebuilt Binary
----------------------------

TODO

Compiling from Source
---------------------

Open ``Fox.xcworkspace`` and build the ``Foxling Compiler`` scheme.
By default, Foxling will automatically download a prebuilt clang snapshot for
use. After building that scheme, just restart Xcode for the plugin to be
installed.

If you prefer to manually download and build clang from source, run
``Foxling/LLVM/download_and_build.sh`` within the ``Foxling/LLVM`` directory,
which follows the directs outlined on `LLVM's site`_. Afterwards, build the
``Foxling Compiler`` scheme. The target will use clang pulled from source
instead of downloading and using the precompiled version.

.. _LLVM's site: http://clang.llvm.org/get_started.html

