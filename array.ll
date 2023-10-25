;-07---- BEGIN ARRAY.LL ----------------------------------------------------------------------------
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Arrays
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%struct.Array = type {
	i32,
	%struct.Boxed*
}

@box.size     = constant i32 ptrtoint (%struct.Boxed* getelementptr (%struct.Boxed, %struct.Boxed* null, i32 1) to i32)
@box.ptr.size = constant i32 ptrtoint (%struct.Boxed** getelementptr (%struct.Boxed*, %struct.Boxed** null, i32 1) to i32)
@array.size   = constant i32 ptrtoint (%struct.Array* getelementptr (%struct.Array, %struct.Array* null, i32 1) to i32)

define void @_EMPTY_ARRAY(%struct.Boxed* %this) {
	%type.ptr  = getelementptr %struct.Boxed, %struct.Boxed* %this, i32 0, i32 0	
	%value.ptr = getelementptr %struct.Boxed, %struct.Boxed* %this, i32 0, i32 1

	%array.size      = load i32, i32* @array.size						; get the size of an array
	%empty.arr.bytes = call i8* @malloc(i32 %array.size)					; allocate a <size> number of bytes
	%empty.arr       = bitcast i8* %empty.arr.bytes to %struct.Array*			; cast the pointer to bytes to one to an array

	%box.size         = load i32, i32* @box.size
	%empty.cont.bytes = call i8* @malloc(i32 %box.size)
	%empty.cont       = bitcast i8* %empty.cont.bytes to %struct.Boxed*

	call void @_SET_CAPACITY(%struct.Array* %empty.arr, i32 0)
	call void @_SET_CONTENTS(%struct.Array* %empty.arr, %struct.Boxed* %empty.cont)

	store ARRAY_TYPE, TYPE_TYPE* %type.ptr

	%value = ptrtoint %struct.Array* %empty.arr to i64
	store i64 %value, i64* %value.ptr

	ret void
}

; DO NOT USE THESE FOUR FUNCTIONS OUTSIDE OF THIS FILE
define i32 @_GET_CAPACITY(%struct.Array* %this) {
	%capacity.ptr  = getelementptr %struct.Array, %struct.Array* %this, i32 0, i32 0
	%capacity = load i32, i32* %capacity.ptr
	ret i32 %capacity
}

define %struct.Boxed* @_GET_CONTENTS(%struct.Array* %this) {
	%array.ptr  = getelementptr %struct.Array, %struct.Array* %this, i32 0, i32 1
	%box = load %struct.Boxed*, %struct.Boxed** %array.ptr
	ret %struct.Boxed* %box
}

define void @_SET_CAPACITY(%struct.Array* %this, i32 %new) {
	%capacity.ptr = getelementptr %struct.Array, %struct.Array* %this, i32 0, i32 0
	store i32 %new, i32* %capacity.ptr
	ret void
}

define void @_SET_CONTENTS(%struct.Array* %this, %struct.Boxed* %new) {
	%array.ptr  = getelementptr %struct.Array, %struct.Array* %this, i32 0, i32 1
	store %struct.Boxed* %new, %struct.Boxed** %array.ptr
	ret void
}
;;;;

define %struct.Array* @_GET_ARRAY(%struct.Boxed* %this) {
	call void @_DEFAULT_IF_NULL(%struct.Boxed* %this, ARRAY_TYPE)				
	; call void @_CHECK_TYPE_E(%struct.Boxed* %this, ARRAY_TYPE)
	%arr.ptr = getelementptr %struct.Boxed, %struct.Boxed* %this, i32 0, i32 1
	%i.arr = load i64, i64* %arr.ptr

	%arr = inttoptr i64 %i.arr to %struct.Array*					
	ret %struct.Array* %arr
}

define %struct.Boxed* @_GET_ARRAY_ELEMENT(%struct.Boxed* %this, %struct.Boxed* %index) {
	call void @_DEFAULT_IF_NULL(%struct.Boxed* %this, ARRAY_TYPE)				
	; call void @_CHECK_TYPE_E(%struct.Boxed* %this, ARRAY_TYPE)

	%i.index = call i32 @_FLOOR(%struct.Boxed* %index)

	call void @_CHECK_POSITIVE_INDEX_E(i32 %i.index)

	%array = call %struct.Array* @_GET_ARRAY(%struct.Boxed* %this)
	%capacity = call i32 @_GET_CAPACITY(%struct.Array* %array)
	%contents = call %struct.Boxed* @_GET_CONTENTS(%struct.Array* %array)
 	
	%is.smaller = icmp slt i32 %i.index, %capacity
	br i1 %is.smaller, label %true, label %false
true:
	%struct.ptr = getelementptr %struct.Boxed*, %struct.Boxed** %contents, i32 %i.index
	ret %struct.Boxed* %struct.ptr
false:
	%i8.ptr.arr = bitcast %struct.Boxed* %contents to i8*

	%box.size = load i32, i32* @box.size
	%new.number.of.elements = add i32 %i.index, 1
	%new.size = mul i32 %box.size, %new.number.of.elements

	%new.contents.bytes = call i8* @realloc(i8* %i8.ptr.arr, i32 %new.size)

	%new.contents = bitcast i8* %new.contents.bytes to %struct.Boxed**
	call void @_SET_CAPACITY(%struct.Array* %array, i32 %new.number.of.elements)
	call void @_SET_CONTENTS(%struct.Array* %array, %struct.Boxed* %new.contents)
	%ret = call %struct.Boxed* @_GET_ARRAY_ELEMENT(%struct.Boxed* %this, %struct.Boxed* %index)
	ret %struct.Boxed* %ret
}

;-07---- END ARRAY.LL ------------------------------------------------------------------------------
