;-01---- BEGIN NUMBER.LL ---------------------------------------------------------------------------;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
; Functions to deal with numbers 								    ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;

; THESE FUNCTIONS DO NOT CHECK IF THE VALUE IS OF THE RIGHT KIND
; IT IS THE CALEE RESPONSABILITY
; number getter
define double @_GET_NUM_VALUE(%struct.Boxed* %value) {
	%value.ptr = getelementptr %struct.Boxed, %struct.Boxed* %value, i32 0, i32 1	; extract the pointer to the number from the struct
	%i.value   = load i64, i64* %value.ptr						; extract the number from the pointer
	%f.value   = bitcast i64 %i.value to double					; cast to a double

	ret double %f.value
}

; number setter
define void @_SET_NUM_VALUE(%struct.Boxed* %self, double %value) {
	%type.ptr  = getelementptr %struct.Boxed, %struct.Boxed* %self, i32 0, i32 0	; extract the pointer to the bool from the struct
	%value.ptr = getelementptr %struct.Boxed, %struct.Boxed* %self, i32 0, i32 1	; extract the pointer to the bool from the struct

	%b.value = bitcast double %value to i64						; cast to a i64

	store NUM_TYPE, TYPE_TYPE* %type.ptr						; insert the type in the result
	store i64 %b.value, i64* %value.ptr						; insert the value in the result

	ret void
}

; `left' and `right' must be numbers, `left' and `right' may be null
#define ARITH_OP(name, op)		\
define void @name(%struct.Boxed* %res, %struct.Boxed* %left, %struct.Boxed* %right) {	NEWLINE\
	call void @_DEFAULT_IF_NULL(%struct.Boxed* %left, NUM_TYPE)			NEWLINE\
	call void @_DEFAULT_IF_NULL(%struct.Boxed* %right, NUM_TYPE)			NEWLINE\
	call void @_CHECK_TYPE_E(%struct.Boxed* %left, NUM_TYPE)			NEWLINE\
	call void @_CHECK_TYPE_E(%struct.Boxed* %right, NUM_TYPE)			NEWLINE\
	%left.float  = call double @_GET_NUM_VALUE(%struct.Boxed* %left)		NEWLINE\
	%right.float = call double @_GET_NUM_VALUE(%struct.Boxed* %right)		NEWLINE\
	%res.value = op double %left.float, %right.float				NEWLINE\
	call void @_SET_NUM_VALUE(%struct.Boxed* %res, double %res.value)		NEWLINE\
	ret void									NEWLINE\
}											NEWLINE

ARITH_OP(MINUS, fsub)
ARITH_OP(MULT, fmul)
ARITH_OP(NUM_PLUS, fadd)

; `value' must be a number, `value' may be null
define void @UNARY_MINUS(%struct.Boxed* %res, %struct.Boxed* %value) {
	call void @_DEFAULT_IF_NULL(%struct.Boxed* %value, NUM_TYPE)
	call void @_CHECK_TYPE_E(%struct.Boxed* %value, NUM_TYPE)
	%float = call double @_GET_NUM_VALUE(%struct.Boxed* %value)
	%m.float = fsub double 0.0, %float
	call void @_SET_NUM_VALUE(%struct.Boxed* %res, double %m.float)
	ret void
}

; an overloaded version of plus that calls `@CONCAT' or `@NUM_PLUS' based on the types of the operands.
; if the first argument is null it checks the type of the second
; if the second is also null it throw an exception (TODO: maybe make it call `@NUM_PLUS')
; Fix the dealing with nulls and numbers
define void @PLUS(%struct.Boxed* %res, %struct.Boxed* %left, %struct.Boxed* %right) {	
	%type.left = call TYPE_TYPE @_GET_TYPE(%struct.Boxed* %left)				
	switch TYPE_TYPE %type.left, label %otherwise [ NULL_TYPE, label %null.type
	                                                NUM_TYPE,  label %number.type		
	                                                STR_TYPE,  label %string.type ]	
null.type:							
	%type.right = call TYPE_TYPE @_GET_TYPE(%struct.Boxed* %right)
	switch TYPE_TYPE %type.right, label %otherwise [ NUM_TYPE,  label %number.type
	                                                 STR_TYPE,  label %string.type ]	
number.type:								
	call void @NUM_PLUS(%struct.Boxed* %res, %struct.Boxed* %left, %struct.Boxed* %right)
	ret void
string.type:						
	call void @CONCAT(%struct.Boxed* %res, %struct.Boxed* %left, %struct.Boxed* %right)
	ret void
otherwise:				
	call void @_NUM_OR_STR_E(%struct.Boxed* %left)
	call void @_NUM_OR_STR_E(%struct.Boxed* %right)
	ret void								
}

; `left' and `right' must be numbers, `left' and `right' may be null, `right' must not be zero
define void @DIV(%struct.Boxed* %res, %struct.Boxed* %left, %struct.Boxed* %right) {	
	call void @_DEFAULT_IF_NULL(%struct.Boxed* %left, NUM_TYPE)				
	call void @_DEFAULT_IF_NULL(%struct.Boxed* %right, NUM_TYPE)			
	call void @_CHECK_TYPE_E(%struct.Boxed* %left, NUM_TYPE)			
	call void @_CHECK_TYPE_E(%struct.Boxed* %right, NUM_TYPE)		
	call void @_CHECK_ZERO_DIV_E(%struct.Boxed* %right)
	%left.float  = call double @_GET_NUM_VALUE(%struct.Boxed* %left)
	%right.float = call double @_GET_NUM_VALUE(%struct.Boxed* %right)
	%res.value = fdiv double %left.float, %right.float			
	call void @_SET_NUM_VALUE(%struct.Boxed* %res, double %res.value)
	ret void							
}								

; `value' must be a number, `value' may be null
define i64 @_FLOOR(%struct.Boxed* %value) {
	call void @_DEFAULT_IF_NULL(%struct.Boxed* %value, NUM_TYPE)				
	call void @_CHECK_TYPE_E(%struct.Boxed* %value, NUM_TYPE)
	%f.value   = call double @_GET_NUM_VALUE(%struct.Boxed* %value)

	%res.value = fptoui double %f.value to i64
	ret i64 %res.value
}

;-01---- END NUMBER.LL -----------------------------------------------------------------------------;
