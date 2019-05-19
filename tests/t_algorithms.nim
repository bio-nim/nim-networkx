# vim: sw=2 ts=2 sts=2 tw=0 et:
import unittest
import networkx/classes/graph
import networkx/algorithms/components/connected
from sequtils import nil
from sets import `==`, len

proc toSet(v: openarray[int]): sets.HashSet[Node] =
  sets.init(result)
  for k in v:
    sets.incl(result, k.Node)

suite "connected":
  setup:
    var g = newBasicGraph()
  test "reachable":
    g.addEdge(1, 2)
    g.addEdge(1, 3)
    g.addEdge(11, 12)
    g.addEdge(11, 13)
    #block:
    #  let r = sequtils.toSeq(reachable(g, 1))
    #  let got = sets.toHashSet(r)
    #  let expected = toSet(@[2, 3])
    #  check got == expected
    #g.addEdge(2, 1)
    block:
      let r = sequtils.toSeq(reachable(g, 1))
      let got = sets.toHashSet(r)
      let expected = toSet(@[1, 2, 3])
      check got == expected
    block:
      let r = sequtils.toSeq(reachable(g, 11))
      let got = sets.toHashSet(r)
      let expected = toSet(@[11, 12, 13])
      check got == expected
  test "connected_components":
    g.addEdge(1, 2)
    g.addEdge(1, 3)
    g.addEdge(11, 12)
    g.addEdge(11, 13)
    #block:
    #  # Fail for non-bidi graph.
    #  expect(NetworkxError):
    #    discard sequtils.toSeq(connected_components(g))
    ## Add reverse edges.
    #g.addEdge(2, 1)
    #g.addEdge(3, 1)
    #g.addEdge(12, 11)
    #g.addEdge(13, 11)
    block:
      let c = sequtils.toSeq(connected_components(g))
      check c.len() == 2
      check c[0].len() == 3
      check c[0].len() == 3
