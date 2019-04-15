# vim: sw=2 ts=2 sts=2 tw=0 et:
from graph import DiGraph, Edge, Node
from tables import `[]=`, `[]`
from sets import nil

export Node

type
  Graph*[Weight] = object of DiGraph
    weights: tables.Table[Edge, Weight]

proc newGraph*[W](): ref Graph[W] =
  new(result)
  graph.initDiGraph(result)
  result.weights = tables.initTable[Edge, W](1024)

proc weight*[W](g: ref Graph[W], u, v: Node): W =
  ## If not found, return default W (probably 0).
  return tables.getOrDefault(g.weights, (u, v))

proc add_edge*[W](g: ref Graph[W], w: W, e: Edge) =
  ## If the edge already existed, update its weight.
  graph.add_edge(g, e.u, e.v)
  g.weights[e] = w

proc add_path*[W](g: ref Graph[W], w: W, nodes: openarray[Node]) =
  var ready = false
  var u: Node
  for v in items(nodes):
    if ready:
      g.add_edge(w, (u, v))
    else:
      ready = true
    u = v

iterator predecessors*[W](g: ref Graph[W], v: Node): (Node, W) =
  for u in sets.items(g.adj[v]):
    yield (u, g.weight(u, v))

iterator successors*[W](g: ref Graph[W], u: Node): (Node, W) =
  for v in sets.items(g.adj[u]):
    yield (v, g.weight(u, v))

when isMainModule:
  block: # test weighted directed Graph
    let g = newGraph[int]()
    g.add_edge(42, (1.Node, 2.Node))
    assert g.weight(1, 2) == 42
    assert g.weight(0, 0) == 0
    g.add_path(99, [1.Node, 2.Node, 3.Node])
    assert g.weight(1, 2) == 99
    assert g.weight(2, 3) == 99
