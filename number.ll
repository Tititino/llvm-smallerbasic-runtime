;-01---- BEGIN NUMBER.LL ---------------------------------------------------------------------------;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
; Functions to deal with numbers 								    ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;

; THESE FUNCTIONS DO NOT CHECK IF THE VALUE IS OF THE RIGHT KIND
; IT IS THE CALEE RESPONSABILITY
define double @_GET_NUM_VALUE(%struct.Boxed* %value) {
	%value.ptr = getelementptr %struct.Boxed, %struct.Boxed* %value, i32 0, i32 1	; extract the pointer to the number from the struct
	%i.value   = load i64, i64* %value.ptr						; extract the number from the pointer
	%f.value   = bitcast i64 %i.value to double					; cast to a double

	ret double %f.value
}

define void @_SET_NUMBER_VALUE(%struct.Boxed* %self, double %value) {
	%type.ptr  = getelementptr %struct.Boxed, %struct.Boxed* %self, i32 0, i32 0	; extract the pointer to the bool from the struct
	%value.ptr = getelementptr %struct.Boxed, %struct.Boxed* %self, i32 0, i32 1	; extract the pointer to the bool from the struct

	%b.value = bitcast double %value to i64						; cast to a i64

	store NUMBER_TYPE, i2* %type.ptr						; insert the type in the result
	store i64 %b.value, i64* %value.ptr						; insert the value in the result

	ret void
}

#define ARITH_OP(name, op)		\
define void @name(%struct.Boxed* %res, %struct.Boxed* %left, %struct.Boxed* %right) {	NEWLINE\
	call void @_CHECK_TYPE_E(%struct.Boxed* %left, NUMBER_TYPE)			NEWLINE\
	call void @_CHECK_TYPE_E(%struct.Boxed* %right, NUMBER_TYPE)			NEWLINE\
	%left.float  = call double @_GET_NUM_VALUE(%struct.Boxed* %left)		NEWLINE\
	%right.float = call double @_GET_NUM_VALUE(%struct.Boxed* %right)		NEWLINE\
	%res.value = op double %left.float, %right.float				NEWLINE\
	call void @_SET_NUMBER_VALUE(%struct.Boxed* %res, double %res.value)		NEWLINE\
	ret void									NEWLINE\
}											NEWLINE

ARITH_OP(MINUS, fsub)
ARITH_OP(MULT, fmul)
ARITH_OP(PLUS, fadd)

define void @OVERLOADED_PLUS(%struct.Boxed* %res, %struct.Boxed* %left, %struct.Boxed* %right) {	
	%type.left = call i2 @_GET_TYPE(%struct.Boxed* %left)
	switch i2 %type.left, label %otherwise [ i2 0, label %number.type		
	                                         i2 1, label %string.type ]	
number.type:								
	call void @_CHECK_TYPE_E(%struct.Boxed* %right, NUMBER_TYPE)			
	call void @PLUS(%struct.Boxed* %res, %struct.Boxed* %left, %struct.Boxed* %right)
	ret void
string.type:						
	call void @_CHECK_TYPE_E(%struct.Boxed* %right, STR_TYPE)			
	call void @CONCAT(%struct.Boxed* %res, %struct.Boxed* %left, %struct.Boxed* %right)
	ret void
otherwise:				
	call void @_CHECK_TYPE_E(%struct.Boxed* %left, NUMBER_TYPE)			
	ret void								
}

define void @DIV(%struct.Boxed* %res, %struct.Boxed* %left, %struct.Boxed* %right) {	
	call void @_CHECK_TYPE_E(%struct.Boxed* %left, NUMBER_TYPE)			
	call void @_CHECK_TYPE_E(%struct.Boxed* %right, NUMBER_TYPE)		
	call void @_CHECK_ZERO_DIV_E(%struct.Boxed* %right)
	%left.float  = call double @_GET_NUM_VALUE(%struct.Boxed* %left)
	%right.float = call double @_GET_NUM_VALUE(%struct.Boxed* %right)
	%res.value = fdiv double %left.float, %right.float			
	call void @_SET_NUMBER_VALUE(%struct.Boxed* %res, double %res.value)
	ret void							
}								

define i64 @_FLOOR(%struct.Boxed* %value) {
	call void @_CHECK_TYPE_E(%struct.Boxed* %value, NUMBER_TYPE)
	%f.value   = call double @_GET_NUM_VALUE(%struct.Boxed* %value)

	%res.value = fptoui double %f.value to i64
	ret i64 %res.value
}
;-01---- END NUMBER.LL -----------------------------------------------------------------------------;
