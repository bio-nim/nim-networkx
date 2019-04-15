# vim: sw=2 ts=2 sts=2 tw=0 et:
import unittest
import networkx/algorithms/shortest_paths/weighted
import networkx/classes/wgraph

type
  Weight = int

generate_procs(Graph[int], int, Node)

suite "Graph":
  setup:
    var g = newGraph[Weight]()
  test "dijkstra3nodes":
    add_path(g, 5.Weight, [1.Node, 2.Node, 9.Node]) # best
    add_path(g, 4.Weight, [1.Node, 3.Node, 7.Node, 9.Node])
    let path = dijkstra_path(g, 1.Node, 9.Node)
    check len(path) == 3  # distance==10
  test "dijkstra4nodes":
    add_path(g, 5.Weight, [1.Node, 2.Node, 9.Node])
    add_path(g, 3.Weight, [1.Node, 3.Node, 7.Node, 9.Node]) # best
    let (distance, path) = single_source_dijkstra(g, 1.Node, 9.Node, Weight.high)
    check len(path) == 4
    check distance == 9
