; ------------------- 
#define NUMBER_TYPE	i2 0
#define STR_TYPE	i2 1
#define BOOL_TYPE	i2 2

#define TRUE		i1 1
#define FALSE		i1 0

%struct.Boxed = type {
	i2,
	i64
}

@true.const  = constant %struct.Boxed { i2 2 , i64 1 }
@false.const = constant %struct.Boxed { i2 2 , i64 0 }

define i1 @CheckType(%struct.Boxed* %value, i2 %expected) {
	%struct.type.ptr = getelementptr %struct.Boxed, %struct.Boxed* %value, i32 0, i32 0
	%type            = load i2, i2* %struct.type.ptr
	%ret             = icmp eq i2 %type, %expected
	ret i1 %ret
}

;-------------
;-- GETTERS --
;-------------
;----------------- extract a number from a box
; THESE FUNCTIONS DO NOT CHECK IF THE VALUE IS OF THE RIGHT KIND
; IT IS THE CALEE RESPONSABILITY
define double @GetNumberValue(%struct.Boxed* %value) {
	%value.ptr = getelementptr %struct.Boxed, %struct.Boxed* %value, i32 0, i32 1	; extract the pointer to the number from the struct
	%i.value   = load i64, i64* %value.ptr						; extract the number from the pointer
	%f.value   = bitcast i64 %i.value to double					; cast to a double

	ret double %f.value
}

;----------------- extract a bool from a box
define i1 @GetBoolValue(%struct.Boxed* %value) {
	%value.ptr = getelementptr %struct.Boxed, %struct.Boxed* %value, i32 0, i32 1	; extract the pointer to the bool from the struct
	%i.value   = load i64, i64* %value.ptr						; extract the bool from the pointer
	%b.value   = trunc i64 %i.value to i1						; truncate the value to one bit

	ret i1 %b.value
}

;----------------- extract a string from a box
declare i8* @GetStringValue(%struct.Boxed* %value)

;-------------
;-- SETTERS --
;-------------
define void @SetNumberValue(%struct.Boxed* %self, double %value) {
	%type.ptr  = getelementptr %struct.Boxed, %struct.Boxed* %self, i32 0, i32 0	; extract the pointer to the bool from the struct
	%value.ptr = getelementptr %struct.Boxed, %struct.Boxed* %self, i32 0, i32 1	; extract the pointer to the bool from the struct

	%b.value = bitcast double %value to i64

	store NUMBER_TYPE, i2* %type.ptr
	store i64 %b.value, i64* %value.ptr

	ret void
}

define void @SetBoolValue(%struct.Boxed* %self, i1 %value) {
	%type.ptr  = getelementptr %struct.Boxed, %struct.Boxed* %self, i32 0, i32 0	; extract the pointer to the bool from the struct
	%value.ptr = getelementptr %struct.Boxed, %struct.Boxed* %self, i32 0, i32 1	; extract the pointer to the bool from the struct

	%i.value = sext i1 %value to i64

	store BOOL_TYPE, i2* %type.ptr
	store i64 %i.value, i64* %value.ptr

	ret void
}

;----------------------------------------------------------------------------------------------------
;--------------- PRINTF -----------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------------
@number.message = constant [4 x i8] c"%f\0A\00"
@string.message = constant [4 x i8] c"%s\0A\00"
@true.message   = constant [6 x i8] c"true\0A\00"
@false.message  = constant [7 x i8] c"false\0A\00"

declare i32 @printf(i8* noalias nocapture, ...)

define void @Print(%struct.Boxed* %value) {
	%is.number = call i1 @CheckType(%struct.Boxed* %value, NUMBER_TYPE)

	br i1 %is.number, label %number, label %not.number
number:
	%f.value = call double @GetNumberValue(%struct.Boxed* %value)
	call i32 (i8*, ...) @printf(i8* getelementptr([4 x i8], [4 x i8]* @number.message, i32 0, i32 0), double %f.value)		
	br label %end
not.number:
	%is.string = call i1 @CheckType(%struct.Boxed* %value, STR_TYPE)
	br i1 %is.string, label %string, label %bool
string:

	br label %end
bool:
	%b.value = call i1 @GetBoolValue(%struct.Boxed* %value)
	br i1 %b.value, label %print.true, label %print.false
print.true:
	call i32 (i8*, ...) @printf(i8* getelementptr([6 x i8], [6 x i8]* @true.message, i32 0, i32 0))		
	br label %end
print.false:
	call i32 (i8*, ...) @printf(i8* getelementptr([7 x i8], [7 x i8]* @false.message, i32 0, i32 0))		
	br label %end
end:
	ret void
}
;- END PRINTF -------------------------------------------------------------------

;-ARITH OPERATIONS---------------------------------------------------------------
#define ARITH_OP(name, op)		\
define void @name(%struct.Boxed* %res, %struct.Boxed* %left, %struct.Boxed* %right) {	NEWLINE\
	%is.number.left  = call i1 @CheckType(%struct.Boxed* %left, NUMBER_TYPE)	NEWLINE\
	%is.number.right = call i1 @CheckType(%struct.Boxed* %right, NUMBER_TYPE)	NEWLINE\
	%left.float  = call double @GetNumberValue(%struct.Boxed* %left)		NEWLINE\
	%right.float = call double @GetNumberValue(%struct.Boxed* %right)		NEWLINE\
	%res.value = op double %left.float, %right.float				NEWLINE\
	call void @SetNumberValue(%struct.Boxed* %res, double %res.value)		NEWLINE\
	ret void									NEWLINE\
}											NEWLINE

ARITH_OP(Add, fadd)
ARITH_OP(Sub, fsub)
ARITH_OP(Mul, fmul)

; !!! DIVISION BY ZERO RUNTIME EXCEPTION !!!
define void @Div(%struct.Boxed* %res, %struct.Boxed* %left, %struct.Boxed* %right) {
	%is.number.left  = call i1 @CheckType(%struct.Boxed* %left, NUMBER_TYPE)
	%is.number.right = call i1 @CheckType(%struct.Boxed* %right, NUMBER_TYPE)

	%left.float  = call double @GetNumberValue(%struct.Boxed* %left)
	%right.float = call double @GetNumberValue(%struct.Boxed* %right)

	%res.value = fdiv double %left.float, %right.float
	call void @SetNumberValue(%struct.Boxed* %res, double %res.value)
	ret void
}

define i64 @Floor(%struct.Boxed* %value) {
	%is.number = call i1 @CheckType(%struct.Boxed* %value, NUMBER_TYPE)
	%f.value   = call double @GetNumberValue(%struct.Boxed* %value)

	%res.value = fptoui double %f.value to i64
	ret i64 %res.value
}
;-END ARITH OPERATIONS-----------------------------------------------------------

;---------------- COMPARISONS ----------------------
#define CMP_OP(name, op)	\
define void @name(%struct.Boxed* %res, %struct.Boxed* %left, %struct.Boxed* %right) { 	NEWLINE\
	%is.number.left = call i1 @CheckType(%struct.Boxed* %left, NUMBER_TYPE)		NEWLINE\
	br i1 %is.number.left, label %number, label %string				NEWLINE\
number:											NEWLINE\
	%is.number.right = call i1 @CheckType(%struct.Boxed* %right, NUMBER_TYPE)	NEWLINE\
	%f.value.left  = call double @GetNumberValue(%struct.Boxed* %left)		NEWLINE\
	%f.value.right = call double @GetNumberValue(%struct.Boxed* %right)		NEWLINE\
	%f.res = fcmp op double %f.value.left, %f.value.right				NEWLINE\
	br label %end									NEWLINE\
string:		; TODO, also otherwise in case of boolean				NEWLINE\
	%s.res = and i1 0, 0								NEWLINE\
	br label %end									NEWLINE\
end:											NEWLINE\
	%bool = phi i1 [%f.res, %number], [%s.res, %string]				NEWLINE\
	call void @SetBoolValue(%struct.Boxed* %res, i1 %bool)				NEWLINE\
	ret void									NEWLINE\
}											NEWLINE

CMP_OP(EQ,  oeq)
CMP_OP(NEQ, one)
CMP_OP(GEQ, oge)
CMP_OP(LEQ, ole)
CMP_OP(LT,  olt)
CMP_OP(GT,  ogt)
;---------------- END COMPARISONS -----------------------

;-- BOOLEAN OPERATIONS ------------------------------------------------------------
#define BOOL_OP(name, op) 	\
define void @name(%struct.Boxed* %res, %struct.Boxed* %left, %struct.Boxed* %right) {	NEWLINE\
	%is.bool.left  = call i1 @CheckType(%struct.Boxed* %left, BOOL_TYPE)		NEWLINE\
	%is.bool.right = call i1 @CheckType(%struct.Boxed* %right, BOOL_TYPE)		NEWLINE\
	%bool.left  = call i1 @GetBoolValue(%struct.Boxed* %left)			NEWLINE\
	%bool.right = call i1 @GetBoolValue(%struct.Boxed* %right)			NEWLINE\
	%b.res = op i1 %bool.left, %bool.right						NEWLINE\
	call void @SetBoolValue(%struct.Boxed* %res, i1 %b.res)				NEWLINE\
	ret void									NEWLINE\
}											NEWLINE

BOOL_OP(And, and)
BOOL_OP(Or, or)
;-- END BOOLEAN OPERATIONS ------------------------------------------------------------

#define NEW_BOX_NO_INIT(name)	\
%name = alloca %struct.Boxed								NEWLINE

#define NEW_BOX(name, val, type)	\
%name = alloca %struct.Boxed								NEWLINE\
call void @Set##type##Value(%struct.Boxed* %name, val)					NEWLINE

;--------------------------------------------------------------------------------
;- END HEADER ~ BEGIN PROGRAM ---------------------------------------------------
;--------------------------------------------------------------------------------
