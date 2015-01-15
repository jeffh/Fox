Fox Documentation
=================

Everything about Fox, the property-based testing tool for Objective-C and
Swift.

Besides this documentation, you can also view the `source on GitHub`_.

.. TODO - write/update docs to use swift code.

.. _source on GitHub: https://github.com/jeffh/Fox

Getting Started
---------------

New to Fox? Or just wanting to have a taste of it? Start here.

- :doc:`Overview </what_is_fox>` - What is Fox? How is it different from other unit testing frameworks?
- :doc:`Installing Fox </installation>` - How to get set up to use Fox.
- :doc:`Basic Tutorial </tutorial>` - Get a feel for using Fox.

Generators
----------

Generators are semi-random data producers that are the core to Fox's capabilities.
Follow the links below to learn more in detail.

- :doc:`Overview </generators>` - What are generators?
- :doc:`Built-in Generators Reference </generators_reference>` - What generators does fox provide?
- :ref:`Building Custom Generators` - How do you build your own generators?
- :ref:`Building Generators with Custom Shrinking` - How do you customize how generators shrink values it generates?

The Runner
----------

All the guts around configuring and executing Fox's verification of properties.

- :doc:`Overview </runner>` - How Fox runs properties and generators.
- :ref:`Configuring Test Generation` - How to customize how Fox generates tests.
- :ref:`Random Number Generators` - The abstraction Fox uses to control random number generation.
- :ref:`Reporters` - The abstraction Fox uses to report test results.

Parallel Testing
----------------

.. warning:: This section and its API is ALPHA and is subject to change.
             Alpha APIs are **not** under :ref:`semantic versioning
             <semantic-versioning>` and can change freely between versions.

How to use Fox to test stateful code that executes in parallel (across multiple
threads). This *does not encompass async testing*.

- :doc:`Installing the Foxling Compiler </parallel/installation>` - How to install Fox's Compiler for parallel testing.
- :doc:`Parallel Testing Tutorial </parallel/tutorial>` - A run-through of parallel testing in Fox.
- :doc:`Fox's Thread Scheduler </parallel/scheduler>` - Technical details of Fox's cooperative threads runtime.
- :doc:`Foxling Compiler </parallel/compiler>` - Technical details of Fox's cooperative threads compiler.

.. TODO - While useful. This is definitely less valuable to write for now.
.. Other Topics
.. ------------
..
.. Other useful topics of Fox that aren't large enough to be in its own category.
..
.. - Integrating Fox into other Testing Libraries
.. - Limitations of Generators
.. - Interesting videos about generative tests
..
.. Infrastructure
.. --------------
..
.. While generators are core to Fox, there's a lot of supporting infrastructure
.. for using and building Generators. They're useful to know in less-common cases:
..
.. Data Structures:
..
.. - Sequence
.. - RoseTree

.. toctree::
   :hidden:
   :maxdepth: 2

   What is Fox? </what_is_fox>
   Installing Fox </installation>
   Installing Foxling </parallel/installation>
   Basic Tutorial </tutorial>
   Parallel Testing Tutorial (Alpha) </parallel/tutorial>

   Generators </generators>
   The Runner & Test Generation </runner>
   Fox's Thread Scheduler (Alpha) </parallel/scheduler>
   The Foxling Compiler (Alpha) </parallel/compiler>

   Built-in Generators Reference </generators_reference>
