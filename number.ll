;-01---- BEGIN NUMBER.LL ---------------------------------------------------------------------------;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
; Functions to deal with numbers 								    ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;

; THESE FUNCTIONS DO NOT CHECK IF THE VALUE IS OF THE RIGHT KIND
; IT IS THE CALEE RESPONSABILITY
define double @_GET_NUMBER_VALUE(%struct.Boxed* %value) {
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
	%is.number.left  = call i1 @_CHECK_TYPE(%struct.Boxed* %left, NUMBER_TYPE)	NEWLINE\
	%is.number.right = call i1 @_CHECK_TYPE(%struct.Boxed* %right, NUMBER_TYPE)	NEWLINE\
	%left.float  = call double @_GET_NUMBER_VALUE(%struct.Boxed* %left)		NEWLINE\
	%right.float = call double @_GET_NUMBER_VALUE(%struct.Boxed* %right)		NEWLINE\
	%res.value = op double %left.float, %right.float				NEWLINE\
	call void @_SET_NUMBER_VALUE(%struct.Boxed* %res, double %res.value)		NEWLINE\
	ret void									NEWLINE\
}											NEWLINE

ARITH_OP(PLUS, fadd)
ARITH_OP(MINUS, fsub)
ARITH_OP(MULT, fmul)
; THIS IS TEMPORARY, I HAVE TO DEAL WITH THE ZERO DIVISION ERROR
ARITH_OP(DIV, fdiv)		

define i64 @_FLOOR(%struct.Boxed* %value) {
	%is.number = call i1 @_CHECK_TYPE(%struct.Boxed* %value, NUMBER_TYPE)
	%f.value   = call double @_GET_NUMBER_VALUE(%struct.Boxed* %value)

	%res.value = fptoui double %f.value to i64
	ret i64 %res.value
}
;-01---- END NUMBER.LL -----------------------------------------------------------------------------;
