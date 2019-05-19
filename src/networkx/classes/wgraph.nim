# vim: sw=2 ts=2 sts=2 tw=0 et:
## Weighted, undirected graph (for now).
from ./graph import BasicGraph, Edge, Node, `$`
from ../util import raiseEx
from hashes import nil
from tables import `[]=`, `[]`
from sets import nil
from strutils import format

export Node

type
  BiEdge* = object
    u, v: Node

proc hash*(e: BiEdge): hashes.Hash =
  return hashes.hash( (e.u, e.v) )

proc getBiEdge(e: Edge): BiEdge =
  if e.v < e.u:
    return BiEdge(u: e.v, v: e.u)
  else:
    return BiEdge(u: e.u, v: e.v)

type
  Graph*[Weight] = object of BasicGraph
    weights: tables.Table[BiEdge, Weight]

proc newGraph*[W](): ref Graph[W] =
  new(result)
  graph.initBasicGraph(result)
  result.weights = tables.initTable[BiEdge, W](1024)

proc weight*[W](g: ref Graph[W], u, v: Node): W =
  ## If not found, return default W (probably 0).
  return tables.getOrDefault(g.weights, getBiEdge((u, v)))

proc add_edge*[W](g: ref Graph[W], w: W, e: Edge) =
  ## If the edge already existed, update its weight.
  graph.add_edge(g, e.u, e.v)
  g.weights[getBiEdge(e)] = w
  #echo format(" Weight($#)=$#", e, g.weights[e])

proc remove_edge*[W](g: ref Graph[W], e: Edge): W {.discardable.} =
  ## Nodes remain in Graph.
  ## Error if e not in graph.
  #echo format("remove_edge($#)", e)
  let existed = tables.take(g.weights, getBiEdge(e), result)
  if not existed:
    let msg = format("$# was not in the weights table for this graph.", e)
    raiseEx(msg)
  graph.remove_edge(g, e.u, e.v)

proc remove_node*[W](g: ref Graph[W], u: Node) =
  assert u in g
  for v in graph.successors(g, u):
    remove_edge[W](g, (u, v))
  graph.remove_node(g, u)

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

## Redundant. Should be called "neighbors()".
iterator successors*[W](g: ref Graph[W], u: Node): (Node, W) =
  for v in sets.items(g.adj[u]):
    yield (v, g.weight(u, v))

when isMainModule:
  block: # test weighted undirected Graph
    let g = newGraph[int]()
    g.add_edge(42, (1.Node, 2.Node))
    assert g.weight(1, 2) == 42
    assert g.weight(0, 0) == 0
    g.add_path(99, [1.Node, 2.Node, 3.Node])
    assert g.weight(1, 2) == 99
    assert g.weight(2, 3) == 99
