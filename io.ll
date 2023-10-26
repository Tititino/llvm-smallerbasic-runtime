;-04---- BEGIN IO.LL -------------------------------------------------------------------------------
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Wrappers to library calls for I/O
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@number.message = constant [6 x i8] c"%.2f\0A\00"
@string.message = constant [4 x i8] c"%s\0A\00"
@true.message   = constant [6 x i8] c"true\0A\00"
@false.message  = constant [7 x i8] c"false\0A\00"

@stdin = external global ptr, align 8

define void @IO.ReadLine(%struct.Boxed* %this) {
	%new.string = call i8* @malloc(i32 STRING_INPUT_BUF_SIZE)	; memory leak

  	%stdin = load ptr, ptr @stdin, align 8
  	call ptr @fgets(ptr noundef %new.string, i32 STRING_INPUT_BUF_SIZE, ptr noundef %stdin)	
	%strlen.0 = call i32 @strlen(i8* %new.string)
	%strlen.1 = sub i32 %strlen.0, 1
	%last.char.ptr = getelementptr i8, i8* %new.string, i32 %strlen.1
	store i8 0, i8* %last.char.ptr						; replace newline with null 

	call void @_SET_STR_VALUE(%struct.Boxed* %this, i8* %new.string)
	ret void
}

define void @IO.WriteLine(%struct.Boxed* %null, %struct.Boxed* %value) {
	%type = call TYPE_TYPE @_GET_TYPE(%struct.Boxed* %value)
	switch TYPE_TYPE %type, label %otherwise [ NUM_TYPE, label %number.type
	                	                   STR_TYPE, label %str.type
					       	   BOOL_TYPE, label %bool.type ]
number.type:
	%f.value = call double @_GET_NUM_VALUE(%struct.Boxed* %value)
	call i32 (i8*, ...) @printf(i8* getelementptr([6 x i8], [6 x i8]* @number.message, i32 0, i32 0), double %f.value)		
	ret void
str.type:
	%s.value = call i8* @_GET_STR_VALUE(%struct.Boxed* %value)
	call i32 (i8*, ...) @printf(i8* getelementptr([4 x i8], [4 x i8]* @string.message, i32 0, i32 0), i8* %s.value)
	ret void
bool.type:
	%b.value = call i1 @_GET_BOOL_VALUE(%struct.Boxed* %value)
	br i1 %b.value, label %print.true, label %print.false
print.true:
	call i32 (i8*, ...) @printf(i8* getelementptr([6 x i8], [6 x i8]* @true.message, i32 0, i32 0))		
	ret void
print.false:
	call i32 (i8*, ...) @printf(i8* getelementptr([7 x i8], [7 x i8]* @false.message, i32 0, i32 0))
	ret void
otherwise:
	switch TYPE_TYPE %type, label %unknown.type [ ARRAY_TYPE, label %array.type ]
array.type:
	call void @_ARRAY_PRINT_E()
	ret void
unknown.type:
	call void @_UNKNOWN_ERROR()
	ret void
}

;-04---- END IO.LL ---------------------------------------------------------------------------------
