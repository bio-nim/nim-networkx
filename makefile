default:
	nim c -r tests/t_add.nim
test:
	nimble test --debug
