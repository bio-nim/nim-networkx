# vim: sw=2 ts=2 sts=2 tw=0 et:
import unittest
import networkx/classes/graph
import networkx/algorithms/components/connected
from sequtils import nil
from sets import `==`

proc toSet(v: openarray[int]): sets.HashSet[Node] =
  sets.init(result)
  for k in v:
    sets.incl(result, k.Node)

suite "algorithms":
  setup:
    var g = newDiGraph()
  test "reachable":
    g.addEdge(1, 2)
    g.addEdge(1, 3)
    g.addEdge(11, 12)
    g.addEdge(11, 13)
    block:
      let r = sequtils.toSeq(reachable(g, 1))
      let got = sets.toHashSet(r)
      let expected = toSet(@[2, 3])
      check got == expected
    g.addEdge(2, 1)
    block:
      let r = sequtils.toSeq(reachable(g, 1))
      let got = sets.toHashSet(r)
      let expected = toSet(@[1, 2, 3])
      check got == expected
    block:
      let r = sequtils.toSeq(reachable(g, 11))
      let got = sets.toHashSet(r)
      let expected = toSet(@[12, 13])
      check got == expected
