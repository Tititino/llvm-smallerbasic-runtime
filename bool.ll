;-02---- BEGIN BOOL.LL -----------------------------------------------------------------------------;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
; Functions to deal with booleans and comparisons						    ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
define i1 @_GET_BOOL_VALUE(%struct.Boxed* %value) {
	%value.ptr = getelementptr %struct.Boxed, %struct.Boxed* %value, i32 0, i32 1	; extract the pointer to the bool from the struct
	%i.value   = load i64, i64* %value.ptr						; extract the bool from the pointer
	%b.value   = trunc i64 %i.value to i1						; truncate the value to one bit

	ret i1 %b.value
}

define void @_SET_BOOL_VALUE(%struct.Boxed* %self, i1 %value) {
	%type.ptr  = getelementptr %struct.Boxed, %struct.Boxed* %self, i32 0, i32 0	; extract the pointer to the bool from the struct
	%value.ptr = getelementptr %struct.Boxed, %struct.Boxed* %self, i32 0, i32 1	; extract the pointer to the bool from the struct

	%i.value = sext i1 %value to i64

	store BOOL_TYPE, TYPE_TYPE* %type.ptr
	store i64 %i.value, i64* %value.ptr

	ret void
}

#define OVERLOADED_CMP(name, fop, op)	\
define void @name(%struct.Boxed* %res, %struct.Boxed* %left, %struct.Boxed* %right) {		NEWLINE\
	%type.left = call TYPE_TYPE @_GET_TYPE(%struct.Boxed* %left)				NEWLINE\
	switch TYPE_TYPE %type.left, label %otherwise [ NULL_TYPE, label %null.type		NEWLINE\
	                                                NUM_TYPE,  label %number.type		NEWLINE\
	                                                STR_TYPE,  label %string.type ]		NEWLINE\
null.type:											NEWLINE\
	%type.right = call TYPE_TYPE @_GET_TYPE(%struct.Boxed* %right)				NEWLINE\
	switch TYPE_TYPE %type.right, label %otherwise [ NUM_TYPE,  label %number.type		NEWLINE\
	                                                 STR_TYPE,  label %string.type ]	NEWLINE\
number.type:											NEWLINE\
	call void @_DEFAULT_IF_NULL(%struct.Boxed* %left, NUM_TYPE)				NEWLINE\
	call void @_DEFAULT_IF_NULL(%struct.Boxed* %right, NUM_TYPE)				NEWLINE\
	call void @_CHECK_TYPE_E(%struct.Boxed* %right, NUM_TYPE)				NEWLINE\
	call void @_CHECK_TYPE_E(%struct.Boxed* %left, NUM_TYPE)				NEWLINE\
	%f.value.left  = call double @_GET_NUM_VALUE(%struct.Boxed* %left)			NEWLINE\
	%f.value.right = call double @_GET_NUM_VALUE(%struct.Boxed* %right)			NEWLINE\
	%f.bool = fcmp fop double %f.value.left, %f.value.right					NEWLINE\
	call void @_SET_BOOL_VALUE(%struct.Boxed* %res, i1 %f.bool)				NEWLINE\
	ret void										NEWLINE\
string.type:											NEWLINE\
	call void @_DEFAULT_IF_NULL(%struct.Boxed* %left, STR_TYPE)				NEWLINE\
	call void @_DEFAULT_IF_NULL(%struct.Boxed* %right, STR_TYPE)				NEWLINE\
	call void @_CHECK_TYPE_E(%struct.Boxed* %left, STR_TYPE)				NEWLINE\
	call void @_CHECK_TYPE_E(%struct.Boxed* %right, STR_TYPE)				NEWLINE\
	%left.str  = call i8* @_GET_STR_VALUE(%struct.Boxed* %left)				NEWLINE\
	%right.str = call i8* @_GET_STR_VALUE(%struct.Boxed* %right)				NEWLINE\
	%strcmp    = call i32 @strcmp(i8* %left.str, i8* %right.str)				NEWLINE\
	%s.bool    = icmp op i32 %strcmp, 0							NEWLINE\
	call void @_SET_BOOL_VALUE(%struct.Boxed* %res, i1 %s.bool)				NEWLINE\
	ret void										NEWLINE\
otherwise:											NEWLINE\
	call void @_CHECK_TYPE_E(%struct.Boxed* %left, NUM_TYPE)				NEWLINE\
	call void @_CHECK_TYPE_E(%struct.Boxed* %right, NUM_TYPE)				NEWLINE\
	ret void										NEWLINE\
}												NEWLINE

OVERLOADED_CMP(EQ, oeq, eq)
OVERLOADED_CMP(NEQ, one, ne)
OVERLOADED_CMP(GEQ, oge, sge)
OVERLOADED_CMP(LEQ, ole, sle)
OVERLOADED_CMP(LT, olt, slt)
OVERLOADED_CMP(GT, ogt, sgt)

#define BOOL_OP(name, op) 	\
define void @name(%struct.Boxed* %res, %struct.Boxed* %left, %struct.Boxed* %right) {	NEWLINE\
	call void @_DEFAULT_IF_NULL(%struct.Boxed* %left, BOOL_TYPE)			NEWLINE\
	call void @_DEFAULT_IF_NULL(%struct.Boxed* %right, BOOL_TYPE)			NEWLINE\
	call void @_CHECK_TYPE_E(%struct.Boxed* %left, BOOL_TYPE)			NEWLINE\
	call void @_CHECK_TYPE_E(%struct.Boxed* %right, BOOL_TYPE)			NEWLINE\
	%bool.left  = call i1 @_GET_BOOL_VALUE(%struct.Boxed* %left)			NEWLINE\
	%bool.right = call i1 @_GET_BOOL_VALUE(%struct.Boxed* %right)			NEWLINE\
	%b.res = op i1 %bool.left, %bool.right						NEWLINE\
	call void @_SET_BOOL_VALUE(%struct.Boxed* %res, i1 %b.res)			NEWLINE\
	ret void									NEWLINE\
}											NEWLINE

BOOL_OP(AND, and)
BOOL_OP(OR, or)
;-02---- END BOOL.LL -------------------------------------------------------------------------------;
