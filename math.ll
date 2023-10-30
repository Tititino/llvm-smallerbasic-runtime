;-05---- BEGIN MATH.LL -----------------------------------------------------------------------------
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Calls to math functions
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; import a specific math function
#define DECLARE_MATH_EXT_FUNC(op)	\
declare double @llvm.op.f64(double)	NEWLINE

DECLARE_MATH_EXT_FUNC(cos)
DECLARE_MATH_EXT_FUNC(sin)
DECLARE_MATH_EXT_FUNC(log)
DECLARE_MATH_EXT_FUNC(sqrt)
DECLARE_MATH_EXT_FUNC(floor)

; call a specific imported math function on a box
; the box must be a number, but may be null
#define MATH_FUNC(name, op) 	\
define void @Math.name(%struct.Boxed* %res, %struct.Boxed* %value) {		NEWLINE\
	call void @_DEFAULT_IF_NULL(%struct.Boxed* %value, NUM_TYPE)		NEWLINE\
	call void @_CHECK_TYPE_E(%struct.Boxed* %value, NUM_TYPE)		NEWLINE\
	%f.value.0 = call double @_GET_NUM_VALUE(%struct.Boxed* %value)		NEWLINE\
	%f.value.1 = call double @llvm.op.f64(double %f.value.0)		NEWLINE\
	call void @_SET_NUM_VALUE(%struct.Boxed* %res, double %f.value.1)	NEWLINE\
	ret void								NEWLINE\
}										NEWLINE

MATH_FUNC(Cos, cos)
MATH_FUNC(Sin, sin)
MATH_FUNC(Sqrt, sqrt)
MATH_FUNC(Log, log)
MATH_FUNC(Floor, floor)

;-05---- END MATH.LL -------------------------------------------------------------------------------
