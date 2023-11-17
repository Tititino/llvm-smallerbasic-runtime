# llvm-smallerbasic-runtime
Runtime library containing definitions and variable that make a SmallerBasic program work.

Each SmallerBasic value and variable is represented by a *box*, or `%struct.Boxed` in the sources.
This is a struct containing two values: a type and a value.
The type may be:
  1. `NULL`
  2. Number
  3. Boolean
  4. String
  5. Array

And the value is casted to a `i64` and depends on the type:
  1. 0 if the type is `NULL`
  2. a `double` if the type is Number
  3. A `i1` if the type is Boolean
  4. A `i8*` if the type is String
  5. A `%struct.Array*` if the type is Array

