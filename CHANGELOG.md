# Changelog

## 0.4.0 (November 13, 2010)

Features:

  - Adds support for disabling method tracing via `.disable_tracing_for`
  - Removes `.enable_tracing_on` & `.peek_list`

## 0.3.0 (November 8, 2010)

Features:

  - Adds support for class & instance method tracing via `.enable_tracing_for`
  - Adds convenience methods for inspecting traced methods within a class
    - `.traced_method_map`
    - `.traced_instance_methods`
    - `.traced_singleton_methods`
  - Deprecates `.enable_tracing_on` & `.peek_list`

## 0.2.1 (November 4, 2010)

Bugfix:

  - Fixed `.enable_tracing_on` to work with both Ruby version 1.8.7 and 1.9.2

## 0.2.0 (October 28, 2010)

Features:

  - Adds support for auto-inclusion

## 0.1.0 (October 25, 2010)

Features:

  - Adds support for instance method tracing
  - Configurable tracer via `Peekaboo.configure`
