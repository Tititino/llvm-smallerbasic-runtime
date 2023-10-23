;-04---- BEGIN IO.LL -------------------------------------------------------------------------------
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Wrappers to library calls for I/O
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@number.message = constant [4 x i8] c"%f\0A\00"
@string.message = constant [4 x i8] c"%s\0A\00"
@true.message   = constant [6 x i8] c"true\0A\00"
@false.message  = constant [7 x i8] c"false\0A\00"

@stdin = external global ptr, align 8

define void @IO.ReadLine(%struct.Boxed* %this) {
	%new.string = call i8* @malloc(i32 100)	; memory leak

  	%stdin = load ptr, ptr @stdin, align 8
  	call ptr @fgets(ptr noundef %new.string, i32 100, ptr noundef %stdin)	; credo inserisca un newline alla fine della stringa

	call void @_SET_STR_VALUE(%struct.Boxed* %this, i8* %new.string)
	ret void
}

define void @IO.WriteLine(%struct.Boxed* %value) {
	%is.number = call i1 @_CHECK_TYPE(%struct.Boxed* %value, NUMBER_TYPE)

	br i1 %is.number, label %number, label %not.number
number:
	%f.value = call double @_GET_NUM_VALUE(%struct.Boxed* %value)
	call i32 (i8*, ...) @printf(i8* getelementptr([4 x i8], [4 x i8]* @number.message, i32 0, i32 0), double %f.value)		
	ret void
not.number:
	%is.string = call i1 @_CHECK_TYPE(%struct.Boxed* %value, STR_TYPE)
	br i1 %is.string, label %string, label %bool
string:
	%s.value = call i8* @_GET_STR_VALUE(%struct.Boxed* %value)
	call i32 (i8*, ...) @printf(i8* getelementptr([4 x i8], [4 x i8]* @string.message, i32 0, i32 0), i8* %s.value)
	ret void
bool:
	%b.value = call i1 @_GET_BOOL_VALUE(%struct.Boxed* %value)
	br i1 %b.value, label %print.true, label %print.false
print.true:
	call i32 (i8*, ...) @printf(i8* getelementptr([6 x i8], [6 x i8]* @true.message, i32 0, i32 0))		
	ret void
print.false:
	call i32 (i8*, ...) @printf(i8* getelementptr([7 x i8], [7 x i8]* @false.message, i32 0, i32 0))		
	ret void
}
;-04---- END IO.LL ---------------------------------------------------------------------------------
