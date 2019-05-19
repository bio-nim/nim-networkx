# vim: sw=2 ts=2 sts=2 tw=0 et:
from ../../classes/graph import Node, contains, add_node, successors, predecessors, add_edge
from "../../util" import raiseEx
from deques import nil
from sequtils import nil
from sets import contains, incl, items
from strutils import `%`, format

export util.NetworkxError


# We might use this someday for directed graphs. But for BasicGraph
# "connected()" is better.
iterator reachable*(g: ref graph.BasicGraph, source: Node): Node =
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

iterator connected*(g: ref graph.BasicGraph, source: Node): Node =
  ## A fast BFS node generator.
  ## Yield all nodes connected to source, including source.
  var
    yielded = sets.initHashSet[Node]()
    nextnodes = deques.initDeque[Node]()
  deques.addLast(nextnodes, source)
  while deques.len(nextnodes) > 0:
    let u = deques.popFirst(nextnodes)
    if u notin yielded:
      yield u
      sets.incl(yielded, u)
      for v in graph.successors(g, u):
        if v notin yielded:
          deques.addLast(nextnodes, v)

iterator connected_components*(g: ref graph.BasicGraph): seq[Node] =
  ## Yield unsorted seqs of connected components.
  ## If the graph is not bidi(symmetric edges), an exception might be thrown.
  var seen = sets.initHashSet[Node]()
  for u in graph.nodes(g):
    if u notin seen:
      var c = sequtils.toSeq(connected(g, u))
      # For directed graphs, we could do this:
      #var c = sequtils.toSeq(reachable(g, u))
      #if u notin c:
      #  echo format(" adj[$#].len==$#", u, g.adj[u].len())
      #  let msg = "Source node not reachable from self. Graph must be undirected or bidirectional."
      #  raiseEx(msg)
      yield c
      for v in c:
        seen.incl(v)
