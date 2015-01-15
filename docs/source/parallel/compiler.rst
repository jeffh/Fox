.. highlight:: objective-c

Foxling Compiler
================

.. warning:: This documentation and API is ALPHA and is subject to change.
             Alpha APIs are **not** under :ref:`semantic versioning
             <semantic-versioning>` and can change freely between versions.

Foxling is a custom compiler which automatically inserts cooperative yield
statements in the code it compiles. This is to support testing parallel code
with :doc:`Fox's thread scheduler <scheduler>`.

Foxling consists mostly as a preprocessor to Apple's Clang (which is different
to the open-sourced Clang). It's actually consists of several (mostly internal)
components:

- **Foxling** - the preprocessor; Implemented as a Clang LibTool.
- **Fling** - the wrapper that combines the preprocessor and Apple's Clang together
- **Fling++** - the wrapper that combines the preprocessor and Apple's Clang++ together
- **Foxling Compiler** - the Xcode Plugin Bundle used for installation.

The Xcode Plugin will tell Xcode to run ``Fling``.

Rewrite Rules for Objective-C
-----------------------------

The Foxling preprocessor uses the open source Clang's C++ API to read ASTs and
rewrite them. Note that the source transformation examples are for
demonstrative purposes. **You should not rely on the implementation details of
the rewritten source**.

Before each statement in a C-block.
    Every statement inside ``{ }`` gets a yield inserted before it.

    Original source::

        - (void)method {
            printSomething();
            for (; true ;) {
                return 1 + 1;
            }
        }

    After Foxling preprocesses::

        - (void)method {
            FOXSchedulerYield();
            printSomething();
            FOXSchedulerYield();
            for (; true ;) {
                FOXSchedulerYield();
                return 1 + 1;
            }
        }

Between read and write operations of (``++``/``--``) unary operators.
    Unaries are expanded to include a yield while preserving the context which
    they execute in.

    Original source::

        - (int)method {
            other_var--;
            return ++variable;
        }

    After Foxling preprocesses::

        // note, variable names are mangled more than shown
        - (int)method {
            ({
                __typeof(variable) v = variable;
                FOXSchedulerYield();
                v--;
                variable = v;
            });
            return ({
                __typeof(variable) v = variable;
                FOXSchedulerYield();
                __typeof(variable) r = ++v;
                variable = v;
                r;
            });
        }

Between objective-c message send calls and computing the receiver.
    Since receivers can also be expressions, yields are inserted.

    Original source::

        - (int)method {
            other_var--;
            return ++variable;
        }

    After Foxling preprocesses::

        // note, variable names are mangled more than shown
        - (int)method {
            ({
                __typeof(variable) v = variable;
                FOXSchedulerYield();
                v--;
                variable = v;
            });
            return ({
                __typeof(variable) v = variable;
                FOXSchedulerYield();
                __typeof(variable) r = ++v;
                variable = v;
                r;
            });
        }

Before setting a property value, but after computing the property's intended value.
    This effectively yields between computation (and potential reads) and writing.

    Original source::

        - (int)method {
            self.variable = 2;
        }

    After Foxling preprocesses::

        // note, variable names are mangled more than shown
        - (int)method {
          self.variable = ({
            __typeof(2) v = 2;
            FOXSchedulerYield();
            v;
          });
        }

Foxling preserves line numbers, so all the preprocessed source are actually on
a single line.

.. warning:: Foxling does not operated on expressions inside macros. This means
             that any potential rewrite rules inside macros are not rewritten.

Rewrite Rules for Swift
-----------------------

Unfortunately, Swift's Clang extension isn't opened source for direct AST
access. Using SourceKit may be a possibility, but at this point in time,
Foxling cannot rewrite Swift code.

You can track this issue here.

