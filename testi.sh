set +e
f() {
	return 1
}
if ! f; then echo hei; fi
echo läpi
