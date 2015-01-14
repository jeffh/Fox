.. highlight:: objective-c

Parallel Testing Tutorial
=========================

Fox supports testing via :ref:`state machines <Testing Stateful APIs>`. Simply
replace all the ``Serial`` API calls to ``Parallel``::

    // generate an arbitrary sequence of API calls that execute in parallel
    id<FOXGenerator> programs = FOXParallelProgram(stateMachine);
    // verify that all the executed commands properly conformed to the state machine.
    FOXAssert(FOXForAll(programs, ^BOOL(FOXProgram *program) {
        FOXExecutedProgram *executedProgram = FOXRunParallelProgram(program, ^id{
            Queue *subject = [Queue new];
            return subject;
        });
        return FOXReturnOrRaisePrettyProgram(executedProgram);
    }));

Program generation is a limited form of parallel.


