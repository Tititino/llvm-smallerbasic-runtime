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

#define CMP_OP(name, fop, op)	\
define void @name(%struct.Boxed* %res, %struct.Boxed* %left, %struct.Boxed* %right) { 	NEWLINE\
	%type.left = call i2 @_GET_TYPE(%struct.Boxed* %left)				NEWLINE\
	switch i2 %type.left, label %otherwise [ i2 0, label %number.type		NEWLINE\
	                                         i2 1, label %string.type ]		NEWLINE\
number.type:										NEWLINE\
	call void @_CHECK_TYPE_E(%struct.Boxed* %right, NUMBER_TYPE)			NEWLINE\
	%f.value.left  = call double @_GET_NUM_VALUE(%struct.Boxed* %left)		NEWLINE\
	%f.value.right = call double @_GET_NUM_VALUE(%struct.Boxed* %right)		NEWLINE\
	%f.res = fcmp fop double %f.value.left, %f.value.right				NEWLINE\
	br label %end									NEWLINE\
string.type:										NEWLINE\
	call void @_CHECK_TYPE_E(%struct.Boxed* %right, STR_TYPE)			NEWLINE\
	%left.str  = call i8* @_GET_STR_VALUE(%struct.Boxed* %left)			NEWLINE\
	%right.str = call i8* @_GET_STR_VALUE(%struct.Boxed* %right)			NEWLINE\
	%len.left  = call i32 @strlen(i8* %left)					NEWLINE\
	%len.right = call i32 @strlen(i8* %right)					NEWLINE\
	%s.res = icmp op i32 %len.left, %len.right					NEWLINE\
	br label %end									NEWLINE\
otherwise:										NEWLINE\
	call void @_CHECK_TYPE_E(%struct.Boxed* %left, NUMBER_TYPE)			NEWLINE\
	ret void									NEWLINE\
end:											NEWLINE\
	%bool = phi i1 [%f.res, %number.type], [%s.res, %string.type]			NEWLINE\
	call void @_SET_BOOL_VALUE(%struct.Boxed* %res, i1 %bool)			NEWLINE\
	ret void									NEWLINE\
}											NEWLINE

CMP_OP(EQ,  oeq, eq)
CMP_OP(NEQ, one, ne)
CMP_OP(GEQ, oge, uge)
CMP_OP(LEQ, ole, sge)
CMP_OP(LT,  olt, slt)
CMP_OP(GT,  ogt, sgt)

#define BOOL_OP(name, op) 	\
define void @name(%struct.Boxed* %res, %struct.Boxed* %left, %struct.Boxed* %right) {	NEWLINE\
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
