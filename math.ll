;-05---- BEGIN MATH.LL -----------------------------------------------------------------------------
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Calls to math functions
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#define DECLARE_MATH_EXT_FUNC(op)	\
declare double @llvm.op.f64(double)	NEWLINE

DECLARE_MATH_EXT_FUNC(cos)
DECLARE_MATH_EXT_FUNC(sin)
DECLARE_MATH_EXT_FUNC(log)
DECLARE_MATH_EXT_FUNC(sqrt)

#define MATH_FUNC(name, op) 	\
define void @Math.name(%struct.Boxed* %res, %struct.Boxed* %value) {		NEWLINE\
	%f.value.0 = call double @_GET_NUM_VALUE(%struct.Boxed* %value)		NEWLINE\
	%f.value.1 = call double @llvm.op.f64(double %f.value.0)		NEWLINE\
	call void @_SET_NUM_VALUE(%struct.Boxed* %res, double %f.value.1)	NEWLINE\
	ret void								NEWLINE\
}										NEWLINE

MATH_FUNC(Cos, cos)
MATH_FUNC(Sin, sin)
MATH_FUNC(Sqrt, sqrt)
MATH_FUNC(Log, log)

;-05---- END MATH.LL -------------------------------------------------------------------------------
