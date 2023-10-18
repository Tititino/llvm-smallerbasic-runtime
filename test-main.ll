define void @main() {
	NEW_BOX_NO_INIT(res)
	NEW_BOX(left, double 1.0, Number)
	NEW_BOX(right, double 2.0, Number)

	call void @Div(%struct.Boxed* %res, %struct.Boxed* %left, %struct.Boxed* %right)

	%f.value = call double @GetNumberValue(%struct.Boxed* %res)
	call void @Print(%struct.Boxed* %res)

	NEW_BOX(b, FALSE, Bool)

	call void @Print(%struct.Boxed* %b)
	ret void
}
