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

	store BOOL_TYPE, i2* %type.ptr
	store i64 %i.value, i64* %value.ptr

	ret void
}

#define CMP_OP(name, op)	\
define void @name(%struct.Boxed* %res, %struct.Boxed* %left, %struct.Boxed* %right) { 	NEWLINE\
	%is.number.left = call i1 @_CHECK_TYPE(%struct.Boxed* %left, NUMBER_TYPE)	NEWLINE\
	br i1 %is.number.left, label %number, label %string				NEWLINE\
number:											NEWLINE\
	%is.number.right = call i1 @_CHECK_TYPE(%struct.Boxed* %right, NUMBER_TYPE)	NEWLINE\
	%f.value.left  = call double @_GET_NUMBER_VALUE(%struct.Boxed* %left)		NEWLINE\
	%f.value.right = call double @_GET_NUMBER_VALUE(%struct.Boxed* %right)		NEWLINE\
	%f.res = fcmp op double %f.value.left, %f.value.right				NEWLINE\
	br label %end									NEWLINE\
string:		; TODO, also otherwise in case of boolean				NEWLINE\
	%s.res = and i1 0, 0								NEWLINE\
	br label %end									NEWLINE\
end:											NEWLINE\
	%bool = phi i1 [%f.res, %number], [%s.res, %string]				NEWLINE\
	call void @_SET_BOOL_VALUE(%struct.Boxed* %res, i1 %bool)			NEWLINE\
	ret void									NEWLINE\
}											NEWLINE

CMP_OP(EQ,  oeq)
CMP_OP(NEQ, one)
CMP_OP(GEQ, oge)
CMP_OP(LEQ, ole)
CMP_OP(LT,  olt)
CMP_OP(GT,  ogt)

#define BOOL_OP(name, op) 	\
define void @name(%struct.Boxed* %res, %struct.Boxed* %left, %struct.Boxed* %right) {	NEWLINE\
	%is.bool.left  = call i1 @_CHECK_TYPE(%struct.Boxed* %left, BOOL_TYPE)		NEWLINE\
	%is.bool.right = call i1 @_CHECK_TYPE(%struct.Boxed* %right, BOOL_TYPE)		NEWLINE\
	%bool.left  = call i1 @_GET_BOOL_VALUE(%struct.Boxed* %left)			NEWLINE\
	%bool.right = call i1 @_GET_BOOL_VALUE(%struct.Boxed* %right)			NEWLINE\
	%b.res = op i1 %bool.left, %bool.right						NEWLINE\
	call void @_SET_BOOL_VALUE(%struct.Boxed* %res, i1 %b.res)			NEWLINE\
	ret void									NEWLINE\
}											NEWLINE

BOOL_OP(AND, and)
BOOL_OP(OR, or)
;-02---- END BOOL.LL -------------------------------------------------------------------------------;
