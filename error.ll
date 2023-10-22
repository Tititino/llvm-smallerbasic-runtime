;-06---- BEGIN ERROR.LL ----------------------------------------------------------------------------
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Runtime error routines
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@number.type.string = constant [7 x i8] c"NUMBER\00"
@string.type.string = constant [7 x i8] c"STRING\00"
@bool.type.string   = constant [5 x i8] c"BOOL\00"
@unknown.type.string   = constant [8 x i8] c"UNKNOWN\00"
@type.error.message = constant [58 x i8] c"*** Runtime exception: expected %s, but got %s (line %d)\0A\00"
@zero.div.message   = constant [54 x i8] c"*** Runtime exception: zero division error (line %d)\0A\00"

@line.number = global i32 0

define i1 @_CHECK_TYPE(%struct.Boxed* %value, i2 %expected) {
	%type            = call i2 @_GET_TYPE(%struct.Boxed* %value)
	%ret             = icmp eq i2 %type, %expected
	ret i1 %ret
}

define i8* @_GET_TYPE_REPR(i2 %type) {
	switch i2 %type, label %unknown.type [ i2 0, label %number.type
	                                       i2 1, label %str.type
					       i2 2, label %bool.type ]
number.type:
	%number.msg  = getelementptr [7 x i8], [7 x i8]* @number.type.string, i32 0, i32 0
	br label %print
str.type:
	%str.msg     = getelementptr [7 x i8], [7 x i8]* @string.type.string, i32 0, i32 0
	br label %print
bool.type:
	%bool.msg    = getelementptr [5 x i8], [5 x i8]* @bool.type.string, i32 0, i32 0
	br label %print
unknown.type:
	%unknown.msg = getelementptr [8 x i8], [8 x i8]* @unknown.type.string, i32 0, i32 0
	br label %print
print:
	%msg = phi i8* [%number.msg, %number.type], [%str.msg, %str.type], [%bool.msg, %bool.type], [%unknown.msg, %unknown.type]
	ret i8* %msg
}

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

define void @_CHECK_TYPE_E(%struct.Boxed* %value, i2 %expected) {
	%type            = call i2 @_GET_TYPE(%struct.Boxed* %value)
	%are.equal       = icmp eq i2 %type, %expected
	br i1 %are.equal, label %end, label %throw.exception
throw.exception:
	%actual.str   = call i8* @_GET_TYPE_REPR(i2 %type)
	%expected.str = call i8* @_GET_TYPE_REPR(i2 %expected)
	%line = load i32, i32* @line.number 
	call i32 (i8*, ...) @printf(i8* getelementptr([58 x i8], [58 x i8]* @type.error.message, i32 0, i32 0), i8* %expected.str, i8* %actual.str, i32 %line )		
	call void @abort()
	ret void
end:
	ret void
}


;-04---- END ERROR.LL ------------------------------------------------------------------------------
