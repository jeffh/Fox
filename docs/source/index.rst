Fox Documentation
=================

Everything about Fox, the property-based testing tool for Objective-C.

Besides this documentation, you can also view the `source on GitHub`_.

.. _source on GitHub: https://github.com/jeffh/Fox

Getting Started
---------------

New to Fox? Or just wanting to have a taste of it? Start here.

- :doc:`Overview </what_is_fox>` - What is Fox?
- :doc:`Installation </installation>` - How to get set up.
- :doc:`Tutorial </tutorial>` - Get a feel for using Fox.

Parallel Testing
----------------

**ALPHA** Fox's infrastructure to test stateful code in parallel (across
multiple threads).

- :doc:`Overview </parallel/overview>` - What and how to test parallel code.
- :doc:`Install the Foxling Compiler </parallel/installation>` - How to set up for advanced parallel testing. This is beyond the :doc:`standard installation </installation>`.
- :doc:`Tutorial </parallel/tutorial>` - Getting a feel for parallel testing.
- :doc:`Foxling </parallel/foxling>` - Technical details of Fox's cooperative threads compiler.

Generators
----------

Generators are semi-random data producers that are the core to Fox's capabilities.
Follow the links below to learn more in detail.

- :doc:`Overview </generators>`
- :doc:`Built-in Generators Reference </generators_reference>`
- :ref:`Building Custom Generators`
- :ref:`Building Generators with Custom Shrinking`

The Runner
----------

All the guts around configuring and executing Fox's verification of properties.

- :doc:`Overview </runner>`
- :ref:`Configuring Test Generation`
- :ref:`Random Number Generators`
- :ref:`Reporters`

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
   Installation </installation>
   Tutorial </tutorial>

   Generators </generators>
   The Runner & Test Generation </runner>

   Built-in Generators Reference </generators_reference>
