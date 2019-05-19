# vim: sw=2 ts=2 sts=2 tw=0 et:
from sequtils import toSeq
from strutils import nil
import unittest
import networkx/classes/graph

func strip(s: string): string =
  return strutils.multiReplace(s, (" ", ""), ("\t", ""), ("\l", ""))

#[
suite "DiGraph":
  setup:
    var g = newDiGraph()
  test "contains":
    check 1 notin g
  test "add_node":
    check 1 notin g
    g.add_node(1)
    check 1 in g
    check 2 notin g
    g.add_node(2)
    check 1 in g
    check 2 in g
  test "remove_node":
    check 1 notin g
    g.add_node(1)
    check 1 in g
    check 2 notin g
    g.add_node(2)
    check 1 in g
    check 2 in g
    g.remove_node(2)
    check 1 in g
    check 2 notin g
    g.remove_node(1)
  test "len":
    check g.len() == 0
    g.add_node(5)
    check g.len() == 1
    g.add_node(7)
    check g.len() == 2
  test "add_edge":
    g.add_edge(1, 2)
    check 1 in g
    check 2 in g
    check (1.Node, 2.Node) in g
    check (2.Node, 1.Node) notin g
  test "remove_edge":
    g.add_edge(1, 2)
    check (1.Node, 2.Node) in g
    check (2.Node, 1.Node) notin g
    g.remove_edge(1, 2)
    check (1.Node, 2.Node) notin g
    check (2.Node, 1.Node) notin g
  test "add_path":
    g.add_path([1.Node, 2.Node, 3.Node])
    check (1.Node, 2.Node) in g
    check (2.Node, 3.Node) in g
    check (3.Node, 2.Node) notin g
    check (2.Node, 1.Node) notin g
  test "number_of_edges":
    check g.number_of_edges() == 0
    g.add_node(1)
    check g.number_of_edges() == 0
    g.add_edge(1, 2)
    check g.number_of_edges() == 1
    g.add_edge(1, 1)
    check g.number_of_edges() == 2
    g.add_edge(2, 2)
    check g.number_of_edges() == 3
  test "has_edge":
    g.add_node(1)
    g.add_node(2)
    check not g.has_edge(1, 2)
    check not g.has_edge(2, 1)
    check (1.Node, 2.Node) notin g
    check (2.Node, 1.Node) notin g
  test "number_of_selfloops":
    check g.number_of_selfloops() == 0
    g.add_node(1)
    check g.number_of_selfloops() == 0
    g.add_edge(1, 2)
    check g.number_of_selfloops() == 0
    g.add_edge(1, 1)
    check g.number_of_selfloops() == 1
    g.add_edge(2, 2)
    check g.number_of_selfloops() == 2
  test "nodes":
    check len(seqUtils.toSeq(g.nodes())) == 0
    g.add_path([1.Node, 2.Node, 3.Node])
    check seqUtils.toSeq(g.nodes()) == @[1.Node, 2.Node, 3.Node]
  test "edges":
    check len(seqUtils.toSeq(g.edges())) == 0
    g.add_path([1.Node, 2.Node, 3.Node])
    check seqUtils.toSeq(g.edges()) == @[(1.Node, 2.Node), (2.Node, 3.Node)]
  test "clear":
    g.add_edge(1, 2)
    check len(g) == 2
    check g.has_edge(1, 2)
    g.add_edge(2, 3)
    check len(g) == 3
    g.clear()
    check len(g) == 0
    check not g.has_edge(1, 3)
  test "$":
    check strip($g) == "{}"
    g.add_path([3.Node, 2.Node, 1.Node])
    check strip($g) == "{1:[],2:[1],3:[2]}"
]#

suite "BasicGraph":
  setup:
    var g = newBasicGraph()
  test "contains":
    check 1 notin g
  test "add_node":
    check 1 notin g
    g.add_node(1)
    check 1 in g
    check 2 notin g
    g.add_node(2)
    check 1 in g
    check 2 in g
  test "remove_node":
    check 1 notin g
    g.add_node(1)
    check 1 in g
    check 2 notin g
    g.add_node(2)
    check 1 in g
    check 2 in g
    g.remove_node(2)
    check 1 in g
    check 2 notin g
    g.remove_node(1)
  test "len":
    check g.len() == 0
    g.add_node(5)
    check g.len() == 1
    g.add_node(7)
    check g.len() == 2
  test "add_edge":
    g.add_edge(1, 2)
    check (1.Node, 2.Node) in g
    check (2.Node, 1.Node) in g
  test "remove_edge":
    g.add_edge(1, 2)
    check (1.Node, 2.Node) in g
    check (2.Node, 1.Node) in g
    g.remove_edge(1, 2)
    check (1.Node, 2.Node) notin g
    check (2.Node, 1.Node) notin g
  test "add_path":
    g.add_path([1.Node, 2.Node, 3.Node])
    check (1.Node, 2.Node) in g
    check (2.Node, 3.Node) in g
    check (3.Node, 2.Node) in g
    check (2.Node, 1.Node) in g
  test "number_of_edges":
    check g.number_of_edges() == 0
    g.add_node(1)
    check g.number_of_edges() == 0
    g.add_edge(1, 2)
    check g.number_of_edges() == 1
    g.add_edge(1, 1)
    check g.number_of_edges() == 2
    g.add_edge(2, 2)
    check g.number_of_edges() == 3
  test "has_edge":
    g.add_node(1)
    g.add_node(2)
    check not g.has_edge(1, 2)
    check not g.has_edge(2, 1)
    check (1.Node, 2.Node) notin g
    check (2.Node, 1.Node) notin g
  test "number_of_selfloops":
    check g.number_of_selfloops() == 0
    g.add_node(1)
    check g.number_of_selfloops() == 0
    g.add_edge(1, 2)
    check g.number_of_selfloops() == 0
    g.add_edge(1, 1)
    check g.number_of_selfloops() == 1
    g.add_edge(2, 2)
    check g.number_of_selfloops() == 2
  test "nodes":
    check len(seqUtils.toSeq(g.nodes())) == 0
    g.add_path([1.Node, 2.Node, 3.Node])
    check seqUtils.toSeq(g.nodes()) == @[1.Node, 2.Node, 3.Node]
  test "edges":
    check len(seqUtils.toSeq(g.edges())) == 0
    g.add_path([1.Node, 2.Node, 3.Node])
    check g.number_of_edges() == 2
    check seqUtils.toSeq(g.edges()) == @[(1.Node, 2.Node), (2.Node, 3.Node)]
    g.clear()
    check len(seqUtils.toSeq(g.edges())) == 0
    g.add_path([1.Node, 2.Node, 2.Node])
    check g.number_of_edges() == 2
    check seqUtils.toSeq(g.edges()) == @[(1.Node, 2.Node), (2.Node, 2.Node)]
  test "clear":
    g.add_edge(1, 2)
    check len(g) == 2
    check g.has_edge(1, 2)
    g.add_edge(2, 3)
    check len(g) == 3
    g.clear()
    check len(g) == 0
    check not g.has_edge(1, 3)
  test "$":
    check strip($g) == "{}"
    g.add_path([3.Node, 2.Node, 1.Node])
    check strip($g) == "{1:[2],2:[1,3],3:[2]}"
