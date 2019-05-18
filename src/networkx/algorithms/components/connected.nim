# vim: sw=2 ts=2 sts=2 tw=0 et:
from ../../classes/graph import Node, contains, add_node, successors, predecessors, add_edge
from "../../util" import raiseEx
from deques import nil
from sets import contains
from strutils import `%`, format


iterator reachable*(g: ref graph.DiGraph, source: Node): Node =
  ## A fast BFS node generator.
  ## Yield all nodes reachable from source. (May or may not include source.)
  var
    reached = sets.initHashSet[Node]()
    nextnodes = deques.initDeque[Node]()
  deques.addLast(nextnodes, source)
  while deques.len(nextnodes) > 0:
    let u = deques.popFirst(nextnodes)
    for v in graph.successors(g, u):
      if v notin reached:
        yield v
        sets.incl(reached, v)
        deques.addLast(nextnodes, v)
