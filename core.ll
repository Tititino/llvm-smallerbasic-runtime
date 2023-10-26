;-00---- BEGIN CORE.LL -----------------------------------------------------------------------------;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
; Core functions and definitions								    ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
#define TYPE_TYPE	i3
#define NULL_TYPE	i3 0
#define NUM_TYPE	i3 1
#define STR_TYPE	i3 2
#define BOOL_TYPE	i3 3
#define ARRAY_TYPE	i3 4

#define STRING_INPUT_BUF_SIZE	100


#define TRUE	i1 1
#define FALSE	i1 0

; needed external functions
declare i8* @malloc(i32)
declare i8* @realloc(i8*, i32)
declare void @abort()
declare i32 @strlen(i8*)
declare i8* @strcpy(i8*, i8*)
declare i8* @strcat(i8*, i8*)
declare i32 @strcmp(i8*, i8*)
declare i32 @printf(i8* noalias nocapture, ...)
declare ptr @fgets(ptr noundef, i32 noundef, ptr noundef) 

#define NEW_BOX_NO_INIT(name)	\
%name = alloca %struct.Boxed					NEWLINE

#define NEW_BOX(name, val, type)	\
%name = alloca %struct.Boxed					NEWLINE\
call void @_SET_##type##_VALUE(%struct.Boxed* %name, val)	NEWLINE

%struct.Boxed = type {
	TYPE_TYPE,	
	i64
}

define TYPE_TYPE @_GET_TYPE(%struct.Boxed* %this) {
	%struct.type.ptr = getelementptr %struct.Boxed, %struct.Boxed* %this, i32 0, i32 0
	%type            = load TYPE_TYPE, TYPE_TYPE* %struct.type.ptr
	ret TYPE_TYPE %type
}

define void @_COPY(%struct.Boxed* %to, %struct.Boxed* %from) {
	%type = call TYPE_TYPE @_GET_TYPE(%struct.Boxed* %from)		
	switch TYPE_TYPE %type, label %otherwise [ NUM_TYPE,   label %number.type
	                 	                   STR_TYPE,   label %string.type
					  	   BOOL_TYPE,  label %bool.type   ]
number.type:							
	%f.value = call double @_GET_NUM_VALUE(%struct.Boxed* %from)
	call void @_SET_NUM_VALUE(%struct.Boxed* %to, double %f.value)
	ret void
string.type:						
	%s.value = call i8* @_GET_STR_VALUE(%struct.Boxed* %from)
	%s.len = call i32 @strlen(i8* %s.value)
	%s.len.1 = add i32 %s.len, 1
	%new.str = call i8* @malloc(i32 %s.len.1)		; memory leak
	call i8* @strcpy(i8* %new.str, i8* %s.value)
	call void @_SET_STR_VALUE(%struct.Boxed* %to, i8* %new.str)
	ret void
bool.type:										
	%b.value = call i1 @_GET_BOOL_VALUE(%struct.Boxed* %from)
	call void @_SET_BOOL_VALUE(%struct.Boxed* %to, i1 %b.value)
	ret void
otherwise:
	switch TYPE_TYPE %type, label %end [ ARRAY_TYPE, label %array.type ]
array.type:
	call void @_ARRAY_COPY_E()
	ret void
end:
	call void @_UNKNOWN_ERROR()	
	ret void
}											

define void @_DEFAULT_IF_NULL(%struct.Boxed* %this, TYPE_TYPE %type) {
	%value.type = call TYPE_TYPE @_GET_TYPE(%struct.Boxed* %this)
	%bool = icmp eq TYPE_TYPE %value.type, 0
	br i1 %bool, label %is.null, label %end
is.null:
	; for some reason if i add a fourth element to the switch i get a linking error that i am
	; too dumb to fix
	switch TYPE_TYPE %type, label %otherwise [ NUM_TYPE,   label %number.type		
	                                           STR_TYPE,   label %string.type 
					           BOOL_TYPE,  label %bool.type  ]
number.type:
	call void @_SET_NUM_VALUE(%struct.Boxed* %this, double 0.0)
	ret void
string.type:
	%empty = call i8* @malloc(i32 1)			; memory leak
	store i8 0, i8* %empty
	call void @_SET_STR_VALUE(%struct.Boxed* %this, i8* %empty)
	ret void
bool.type:
	call void @_SET_BOOL_VALUE(%struct.Boxed* %this, FALSE)
	ret void
otherwise:
	switch TYPE_TYPE %type, label %end [ ARRAY_TYPE, label %array.type ]
array.type:
	call void @_EMPTY_ARRAY(%struct.Boxed* %this)	
	ret void
end:
	ret void
}

;-00---- END CORE.LL -------------------------------------------------------------------------------;
