default: test-nimble
test:
	nim c -r tests/t_weighted.nim
	nim c -r tests/t_graph.nim
test-nimble:
	nimble test --debug
others:
	nim c -r src/networkx/algorithms/shortest_paths/weighted.nim
	nim c -r src/networkx/algorithms/shortest_paths/unweighted.nim
	nim c -r src/networkx/classes/wgraph.nim
	nim c -r src/networkx/classes/graph.nim
