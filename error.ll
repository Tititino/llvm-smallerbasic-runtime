;-06---- BEGIN ERROR.LL ----------------------------------------------------------------------------
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Runtime error routines
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@number.type.string  = constant [7 x i8]  c"NUMBER\00"
@string.type.string  = constant [7 x i8]  c"STRING\00"
@bool.type.string    = constant [5 x i8]  c"BOOL\00"
@array.type.string   = constant [6 x i8]  c"ARRAY\00"
@unknown.type.string = constant [8 x i8]  c"UNKNOWN\00"
@type.error.message  = constant [58 x i8] c"*** Runtime exception: expected %s, but got %s (line %d)\0A\00"
@zero.div.message    = constant [54 x i8] c"*** Runtime exception: zero division error (line %d)\0A\00"
@unknown.error       = constant [48 x i8] c"*** Runtime exception: unknown error (line %d)\0A\00"

@line.number = global i32 0

; return a boolean saying whether a box has type `expected' or not.
define i1 @_CHECK_TYPE(%struct.Boxed* %value, TYPE_TYPE %expected) {
	%type            = call TYPE_TYPE @_GET_TYPE(%struct.Boxed* %value)
	%ret             = icmp eq TYPE_TYPE %type, %expected
	ret i1 %ret
}

; return the string represetation of a type.
define i8* @_GET_TYPE_REPR(TYPE_TYPE %type) {
	switch TYPE_TYPE %type, label %otherwise [ NUM_TYPE, label %number.type
	                	                   STR_TYPE, label %str.type
					       	   BOOL_TYPE, label %bool.type ]
number.type:
	%number.msg  = getelementptr [7 x i8], [7 x i8]* @number.type.string, i32 0, i32 0
	br label %print
str.type:
	%str.msg     = getelementptr [7 x i8], [7 x i8]* @string.type.string, i32 0, i32 0
	br label %print
bool.type:
	%bool.msg    = getelementptr [5 x i8], [5 x i8]* @bool.type.string, i32 0, i32 0
	br label %print
otherwise:
	switch TYPE_TYPE %type, label %unknown.type [ ARRAY_TYPE, label %array.type ]
array.type:
	%array.msg = getelementptr [7 x i8], [7 x i8]* @array.type.string, i32 0, i32 0
	br label %end.otherwise
unknown.type:
	%unknown.msg = getelementptr [8 x i8], [8 x i8]* @unknown.type.string, i32 0, i32 0
	br label %end.otherwise
end.otherwise:
	%otherwise.msg = phi i8* [%array.msg, %array.type], [%unknown.msg, %unknown.type]
	br label %print
print:
	%msg = phi i8* [%number.msg, %number.type], [%str.msg, %str.type], [%bool.msg, %bool.type], [%otherwise.msg, %end.otherwise]
	ret i8* %msg
}

; throw a generic error
define void @_UNKNOWN_ERROR() {
	%line = load i32, i32* @line.number 
	call i32 (i8*, ...) @printf(i8* getelementptr([47 x i8], [47 x i8]* @unknown.error, i32 0, i32 0), i32 %line)
	call void @abort()
	ret void	
}

; throw a zero division error if `value' is zero
define void @_CHECK_ZERO_DIV_E(%struct.Boxed* %value) {
	%num = call double @_GET_NUM_VALUE(%struct.Boxed* %value)
	%is.zero = fcmp oeq double %num, 0.0
	br i1 %is.zero, label %true, label %false
true:
	%line = load i32, i32* @line.number 
	call i32 (i8*, ...) @printf(i8* getelementptr([54 x i8], [54 x i8]* @zero.div.message, i32 0, i32 0), i32 %line)
	call void @abort()
	ret void	
false:
	ret void
}

; throw a type error if `value''s type is different from `expected'
define void @_CHECK_TYPE_E(%struct.Boxed* %value, TYPE_TYPE %expected) {
	%type            = call TYPE_TYPE @_GET_TYPE(%struct.Boxed* %value)
	%are.equal       = icmp eq TYPE_TYPE %type, %expected
	br i1 %are.equal, label %end, label %throw.exception
throw.exception:
	%actual.str   = call i8* @_GET_TYPE_REPR(TYPE_TYPE %type)
	%expected.str = call i8* @_GET_TYPE_REPR(TYPE_TYPE %expected)
	%line = load i32, i32* @line.number 
	call i32 (i8*, ...) @printf(i8* getelementptr([58 x i8], [58 x i8]* @type.error.message, i32 0, i32 0), i8* %expected.str, i8* %actual.str, i32 %line )		
	call void @abort()
	ret void
end:
	ret void
}

; throw a negative index error if `index' is less than zero
@negative.index.msg = constant [57 x i8] c"*** Runtime exception: %d is a negative index (line %d)\0A\00"
define void @_CHECK_POSITIVE_INDEX_E(i32 %index) {
	%is.negative = icmp slt i32 %index, 0
	br i1 %is.negative, label %true, label %false
true:
	%line = load i32, i32* @line.number 
	call i32 (i8*, ...) @printf(i8* getelementptr([57 x i8], [57 x i8]* @negative.index.msg, i32 0, i32 0), i32 %index, i32 %line)
	call void @abort()
	ret void
false:
	ret void
}

; throw an array copy error if the user is trying to copy an array
@array.copy.msg = constant [75 x i8] c"*** Runtime exception: array copy (<arr> = <arr>) not supported (line %d)\0A\00"
define void @_ARRAY_COPY_E() {
	%line = load i32, i32* @line.number 
	call i32 (i8*, ...) @printf(i8* getelementptr([75 x i8], [75 x i8]* @array.copy.msg, i32 0, i32 0), i32 %line )		
	call void @abort()
	ret void
}

; throw an array print error if the user is trying to print an array
@array.print.msg = constant [63 x i8] c"*** Runtime exception: array printing not supported (line %d)\0A\00"
define void @_ARRAY_PRINT_E() {
	%line = load i32, i32* @line.number 
	call i32 (i8*, ...) @printf(i8* getelementptr([63 x i8], [63 x i8]* @array.print.msg, i32 0, i32 0), i32 %line )		
	call void @abort()
	ret void
}

; throw an error if the input has not type STRING or NUM
@str.or.num.msg = constant [93 x i8] c"*** Runtime exception: expected a value of type NUMBER or STRING, instead got %s at line %d\0A\00"
define void @_NUM_OR_STR_E(%struct.Boxed* %this) {
	%type = call TYPE_TYPE @_GET_TYPE(%struct.Boxed* %this)
	switch TYPE_TYPE %type, label %problem[ NUM_TYPE, label %no.problem
	                	                STR_TYPE, label %no.problem ]
problem:
	%line = load i32, i32* @line.number 
	%type.repr = call i8* @_GET_TYPE_REPR(TYPE_TYPE %type)
	call i32 (i8*, ...) @printf(i8* getelementptr([93 x i8], [93 x i8]* @str.or.num.msg, i32 0, i32 0), i8* %type.repr, i32 %line)		
	call void @abort()
	ret void
no.problem:
	ret void
}

;-04---- END ERROR.LL ------------------------------------------------------------------------------
