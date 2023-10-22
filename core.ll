;-00---- BEGIN CORE.LL -----------------------------------------------------------------------------;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
; Core functions and definitions								    ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
#define NUMBER_TYPE	i2 0
#define STR_TYPE	i2 1
#define BOOL_TYPE	i2 2

; needed external functions
declare i8* @malloc(i32)
declare i32 @strlen(i8*)
declare void @abort()
declare i8* @strcpy(i8*, i8*)
declare i8* @strcat(i8*, i8*)
declare i32 @printf(i8* noalias nocapture, ...)
declare ptr @fgets(ptr noundef, i32 noundef, ptr noundef) 

#define NEW_BOX_NO_INIT(name)	\
%name = alloca %struct.Boxed					NEWLINE

#define NEW_BOX(name, val, type)	\
%name = alloca %struct.Boxed					NEWLINE\
call void @_SET_##type##_VALUE(%struct.Boxed* %name, val)	NEWLINE


%struct.Boxed = type {
	i2,
	i64
}

define i2 @_GET_TYPE(%struct.Boxed* %this) {
	%struct.type.ptr = getelementptr %struct.Boxed, %struct.Boxed* %this, i32 0, i32 0
	%type            = load i2, i2* %struct.type.ptr
	ret i2 %type
}

define void @COPY(%struct.Boxed* %to, %struct.Boxed* %from) {
	%is.number = call i1 @_CHECK_TYPE(%struct.Boxed* %from, NUMBER_TYPE)

	br i1 %is.number, label %number, label %not.number
number:
	%f.value = call double @_GET_NUM_VALUE(%struct.Boxed* %from)
	call void @_SET_NUMBER_VALUE(%struct.Boxed* %to, double %f.value)
	ret void
not.number:
	%is.string = call i1 @_CHECK_TYPE(%struct.Boxed* %from, STR_TYPE)
	br i1 %is.string, label %string, label %bool
string:
	%s.value = call i8* @_GET_STR_VALUE(%struct.Boxed* %from)
	%s.len = call i32 @strlen(i8* %s.value)
	%s.len.1 = add i32 %s.len, 1
	%new.str = call i8* @malloc(i32 %s.len.1)		; memory leak
	call i8* @strcpy(i8* %new.str, i8* %s.value)
	call void @_SET_STR_VALUE(%struct.Boxed* %to, i8* %new.str)
	ret void
bool:
	%b.value = call i1 @_GET_BOOL_VALUE(%struct.Boxed* %from)
	call void @_SET_BOOL_VALUE(%struct.Boxed* %to, i1 %b.value)
	ret void
}

;-00---- END CORE.LL -------------------------------------------------------------------------------;
