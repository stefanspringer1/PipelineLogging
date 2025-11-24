# PipelineLogging

A binding of the [Logging](https://github.com/stefanspringer1/Logging) library to the [Pipeline](https://github.com/stefanspringer1/PipelineLogging) library.

The Pipeline library allows the use of other logging libraries, so you can alternatively use a logging library of your choice. However, if no such logging library is specified or available, or if you simply want to try out the Pipeline library, this package provides a quick starting point.

Note that the Pipeline library's logging concept requires that a binding to a logging library must first be created, and then the logging in the application code can be formulated independently of the actual logging library. This means the logging library can easily be changed later without having to replace the logging commands.

This logging library already includes such a binding to the Pipeline library.
