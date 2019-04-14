quick:
	nim c -r src/networkx/classes/graph.nim
default:
	nim c -r tests/t_graph.nim
test:
	nimble test --debug
