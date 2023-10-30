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

; Create a function named `name', that compares two numbers using `fop' or compares two string using
; `op' (strcmp(str1, str), 0) otherwise.
; Both operands may be null, but must be of the same type.
; @param res 	the result pointer
; @param left 	the left operand
; @param right 	the right operand
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

OVERLOADED_CMP(GEQ, oge, sge)
OVERLOADED_CMP(LEQ, ole, sle)
OVERLOADED_CMP(LT, olt, slt)
OVERLOADED_CMP(GT, ogt, sgt)

OVERLOADED_CMP(SAME_EQ, oeq, eq)
OVERLOADED_CMP(SAME_NEQ, one, ne)

; Equality (and inequality) is defined separaly because it may accept operands of different types.
; In every other way it is the same as OVERLOADED_CMP.
; TODO: make it work with null values.
define void @EQ(%struct.Boxed* %res, %struct.Boxed* %left, %struct.Boxed* %right) {		
	%type.left  = call TYPE_TYPE @_GET_TYPE(%struct.Boxed* %left)				
	%type.right = call TYPE_TYPE @_GET_TYPE(%struct.Boxed* %right)
	%are.same = icmp eq TYPE_TYPE %type.left, %type.right
	br i1 %are.same, label %yes.same, label %no.same
yes.same:
	call void @SAME_EQ(%struct.Boxed* %res, %struct.Boxed* %left, %struct.Boxed* %right)
	ret void
no.same:
	%is.left.str  = call i1 @_CHECK_TYPE(%struct.Boxed* %left, STR_TYPE)
	%is.left.num  = call i1 @_CHECK_TYPE(%struct.Boxed* %left, NUM_TYPE)
	%is.right.str = call i1 @_CHECK_TYPE(%struct.Boxed* %right, STR_TYPE)
	%is.right.num = call i1 @_CHECK_TYPE(%struct.Boxed* %right, NUM_TYPE)

	%is.left.valid = or i1 %is.left.str, %is.left.num
	%is.right.valid = or i1 %is.right.str, %is.right.num
	%are.both.valid = and i1 %is.left.valid, %is.right.valid

	br i1 %are.both.valid, label %yes.valid, label %no.valid
yes.valid:
	call void @_SET_BOOL_VALUE(%struct.Boxed* %res, FALSE)
	ret void
no.valid:
	call void @_NUM_OR_STR_E(%struct.Boxed* %left)
	call void @_NUM_OR_STR_E(%struct.Boxed* %right)
	ret void										
}												

define void @NEQ(%struct.Boxed* %res, %struct.Boxed* %left, %struct.Boxed* %right) {		
	%type.left  = call TYPE_TYPE @_GET_TYPE(%struct.Boxed* %left)				
	%type.right = call TYPE_TYPE @_GET_TYPE(%struct.Boxed* %right)
	%are.same = icmp eq TYPE_TYPE %type.left, %type.right
	br i1 %are.same, label %yes.same, label %no.same
yes.same:
	call void @SAME_NEQ(%struct.Boxed* %res, %struct.Boxed* %left, %struct.Boxed* %right)
	ret void
no.same:
	%is.left.str  = call i1 @_CHECK_TYPE(%struct.Boxed* %left, STR_TYPE)
	%is.left.num  = call i1 @_CHECK_TYPE(%struct.Boxed* %left, NUM_TYPE)
	%is.right.str = call i1 @_CHECK_TYPE(%struct.Boxed* %right, STR_TYPE)
	%is.right.num = call i1 @_CHECK_TYPE(%struct.Boxed* %right, NUM_TYPE)

	%is.left.valid = or i1 %is.left.str, %is.left.num
	%is.right.valid = or i1 %is.right.str, %is.right.num
	%are.both.valid = and i1 %is.left.valid, %is.right.valid

	br i1 %are.both.valid, label %yes.valid, label %no.valid
yes.valid:
	call void @_SET_BOOL_VALUE(%struct.Boxed* %res, TRUE)
	ret void
no.valid:
	call void @_NUM_OR_STR_E(%struct.Boxed* %left)
	call void @_NUM_OR_STR_E(%struct.Boxed* %right)
	ret void										
}												

; Arguments may be null, arguments must be booleans
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
