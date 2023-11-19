# llvm-smallerbasic-runtime
Runtime library containing definitions and variable that make a SmallerBasic program work.

Since these files use the C macro system, they must be preprocessed before being used.
The user may call `make out/ruintime.ll` to generate a single file.

Furthermore the user may provide a `main.ll` file and use `make all`/`make clean` to compile it against the library.

## Structure
```
array.ll  <- functions to manipulate arrays, mainly @_GET_ARRAY_ELEMENT
bool.ll   <- functions to manipulate bool containing boxes, and operations on bools
number.ll <- functions to manipulate number containing boxes, and operations on numbers
io.ll     <- functions concerning I/O
math.ll   <- math functions
string.ll <- functions to manipulate string containing boxes, and operations on strings
error.ll  <- functions to throw various errors
core.ll   <- fundamental functions and type definitions
```

## The box
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

## The array
Arrays are represented by a struct called `%struct.Array`.
This has two fields: a capacity and the array of `%struct.Boxed*`.

## Line numbers
Error messages thrown by `error.ll` reference the original SmallerBasic source line number, this is achieved using a global variable `@line` and a series of `store`s threaded in the LLVM IR during compilation.

## Problems
`@malloc` and `@realloc` are used without gc.
