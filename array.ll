;-07---- BEGIN ARRAY.LL ----------------------------------------------------------------------------
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Arrays
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%struct.Array = type {	
	i32,
	%struct.Boxed*
}

; sizeof(Boxed)
@box.size     = constant i32 ptrtoint (%struct.Boxed* getelementptr (%struct.Boxed, %struct.Boxed* null, i32 1) to i32)
; sizoef(Array)
@array.size   = constant i32 ptrtoint (%struct.Array* getelementptr (%struct.Array, %struct.Array* null, i32 1) to i32)

; init a Boxed valuue to an empty array
; @param this the struct.Boxed to be initialized to an empty array
define void @_EMPTY_ARRAY(%struct.Boxed* %this) {
	%type.ptr  = getelementptr %struct.Boxed, %struct.Boxed* %this, i32 0, i32 0	
	%value.ptr = getelementptr %struct.Boxed, %struct.Boxed* %this, i32 0, i32 1

	%array.size      = load i32, i32* @array.size						; get the size of an array
	%empty.arr.bytes = call i8* @malloc(i32 %array.size)					; allocate a <size> number of bytes
	%empty.arr       = bitcast i8* %empty.arr.bytes to %struct.Array*			; cast the pointer to bytes to one to an array

	call void @_SET_CAPACITY(%struct.Array* %empty.arr, i32 0)
	call void @_SET_CONTENTS(%struct.Array* %empty.arr, %struct.Boxed* null)		; init to null the contetns

	store ARRAY_TYPE, TYPE_TYPE* %type.ptr

	%value = ptrtoint %struct.Array* %empty.arr to i64
	store i64 %value, i64* %value.ptr

	ret void
}

; These five functions are intended to be used inside this file
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

define %struct.Array* @_GET_ARRAY(%struct.Boxed* %this) {
	call void @_DEFAULT_IF_NULL(%struct.Boxed* %this, ARRAY_TYPE)			; if this is null, the default it to a boxed array
	call void @_CHECK_TYPE_E(%struct.Boxed* %this, ARRAY_TYPE)			; else if the type of this is not ARRAY_TYPE throw an exception
	%arr.ptr = getelementptr %struct.Boxed, %struct.Boxed* %this, i32 0, i32 1	 
	%i.arr = load i64, i64* %arr.ptr						

	%arr = inttoptr i64 %i.arr to %struct.Array*					
	ret %struct.Array* %arr
}

; get the index th element out of this boxed array.
; if the array is smaller than the index the contents are expanded
; @param this	the box, must be NULL or an array box or else an error is thrown
; @param index	the index, must be NULL or of NUMBER type
; @returns the index-th element of this
define %struct.Boxed* @_GET_ARRAY_ELEMENT(%struct.Boxed* %this, %struct.Boxed* %index) {
	call void @_DEFAULT_IF_NULL(%struct.Boxed* %this, ARRAY_TYPE)		; if (this is null) then default(this)	
	call void @_CHECK_TYPE_E(%struct.Boxed* %this, ARRAY_TYPE)		; assert(this.type == ARRAY)

	%i.index = call i32 @_FLOOR(%struct.Boxed* %index)			; i = floor(index)

	call void @_CHECK_POSITIVE_INDEX_E(i32 %i.index)			; assert(i >= 0)

	%array = call %struct.Array* @_GET_ARRAY(%struct.Boxed* %this)		; array = this.array
	%capacity = call i32 @_GET_CAPACITY(%struct.Array* %array)		; capacity = array.capacity
	%contents = call %struct.Boxed* @_GET_CONTENTS(%struct.Array* %array)	; contents = array.contents
 	
	%is.smaller = icmp slt i32 %i.index, %capacity				; b = i < capacity
	br i1 %is.smaller, label %true, label %false				; 
true:
	%struct.ptr = getelementptr %struct.Boxed, %struct.Boxed* %contents, i32 %i.index
	ret %struct.Boxed* %struct.ptr
false:
	%i8.ptr.arr = bitcast %struct.Boxed* %contents to i8*			; cast the pointer to a byte pointer

	%box.size = load i32, i32* @box.size					; sizeof(Boxed)
	%new.number.of.elements = add i32 %i.index, 1				; new-capacity = index + 1
	%new.size = mul i32 %box.size, %new.number.of.elements			; bytes-to-alloc = new-capacity * siezeof(Boxed)

	%new.contents.bytes = call i8* @realloc(i8* %i8.ptr.arr, i32 %new.size)	; realloc, this may cause bugs since the memory is uninitialized, and the use may access a bad-box

	%new.contents = bitcast i8* %new.contents.bytes to %struct.Boxed*	; cast back to a [Boxed]
	call void @_SET_CAPACITY(%struct.Array* %array, i32 %new.number.of.elements)
	call void @_SET_CONTENTS(%struct.Array* %array, %struct.Boxed* %new.contents)
	%ret = call %struct.Boxed* @_GET_ARRAY_ELEMENT(%struct.Boxed* %this, %struct.Boxed* %index)
	ret %struct.Boxed* %ret
}

;-07---- END ARRAY.LL ------------------------------------------------------------------------------
