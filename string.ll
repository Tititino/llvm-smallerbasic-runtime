;-03---- BEGIN STRING.LL ---------------------------------------------------------------------------;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
; Functions to deal with STRINGS								    ;
; Inspired by https://mapping-high-level-constructs-to-llvm-ir.readthedocs.io/en/ section on 	    ;
; strings											    ;
; Strings are immutable, but there is no gc   							    ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
; takes the ownership of the string
define void @_SET_STR_VALUE(%struct.Boxed* %self, i8* %value) nounwind {
	%type.ptr  = getelementptr %struct.Boxed, %struct.Boxed* %self, i32 0, i32 0	; extract the pointer to the bool from the struct
	%value.ptr = getelementptr %struct.Boxed, %struct.Boxed* %self, i32 0, i32 1	; extract the pointer to the bool from the struct

	%s.value = ptrtoint i8* %value to i64						; cast to a i64

	store STR_TYPE, TYPE_TYPE* %type.ptr						; insert the type in the result
	store i64 %s.value, i64* %value.ptr						; insert the value in the result

	ret void
}

define i8* @_GET_STR_VALUE(%struct.Boxed* %this) nounwind {
	%value.ptr = getelementptr %struct.Boxed, %struct.Boxed* %this, i32 0, i32 1	; extract the pointer to the string from the struct
	%i.value   = load i64, i64* %value.ptr						; extract the string pointer from the pointer
	%s.value   = inttoptr i64 %i.value to i8*					; cast to a double

	ret i8* %s.value
}

define void @CONCAT(%struct.Boxed* %res, %struct.Boxed* %left, %struct.Boxed* %right) {
	call void @_DEFAULT_IF_NULL(%struct.Boxed* %left, STR_TYPE)
	call void @_DEFAULT_IF_NULL(%struct.Boxed* %right, STR_TYPE)
	call void @_CHECK_TYPE_E(%struct.Boxed* %left, STR_TYPE)
	call void @_CHECK_TYPE_E(%struct.Boxed* %right, STR_TYPE)
	%left.string = call i8* @_GET_STR_VALUE(%struct.Boxed* %left)
	%right.string = call i8* @_GET_STR_VALUE(%struct.Boxed* %right)

	%len.left = call i32 @strlen(i8* %left.string)
	%len.right = call i32 @strlen(i8* %right.string)

	%len.new.0 = add i32 %len.left, %len.right
	%len.new = add i32 %len.new.0, 1			; the new length is length(`left') + `length(`right') + 1 (null terminating byte)

	%new.string = call i8* @malloc(i32 %len.new)		; memory leak

	call i8* @strcpy(i8* %new.string, i8* %left.string)
	call i8* @strcat(i8* %new.string, i8* %right.string)

	call void @_SET_STR_VALUE(%struct.Boxed* %res, i8* %new.string)

	ret void
}
;-03---- END STRING.LL -----------------------------------------------------------------------------;
