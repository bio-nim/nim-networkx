# vim: sw=2 ts=2 sts=2 tw=0 et:
## TOTALLY NOT READY.
## I realized that we do not need directed graphs yet, and
## DiGraph was buggy. So for now, have have only BasicGraph (undirected),
## which can be weighted.
from sequtils import nil
from hashes import nil
from strutils import format
from sets import incl, excl, contains, isValid
from tables import `[]`, `[]=`, keys, del, pairs

## None of these procs should be considered thread-safe.

type
  ## We use simple integers for Nodes, Weights, etc.
  ## If you need specific types, you must keep your own mapping separately.
  Node* = int32
  Edge* = tuple[u, v: Node]

  DiGraph* = object of RootObj
    adj*: tables.Table[Node, sets.HashSet[Node]] ## Adjacency
    #node_attrs: tables.Table[AttrKey, ref tables.Table[Node, Attribute]] ## [key][node] == attr
    #edge_attrs: tables.Table[AttrKey, ref tables.Table[Edge, Attribute]] ## [key][(u, v)] == attr
    #num_unique_edges: int # where 2,3 and 3,2 are counted only once
    #num_self_edges: int
  BasicGraph* = object of DiGraph

proc none*(g: ref DiGraph): Node =
  ## This is used as a sentinel in graph algs, so this value should *never*
  ## be inserted into the Graph.
  return 0.Node

proc initDiGraph*(g: ref DiGraph) =
  g.adj = tables.initTable[Node, sets.HashSet[Node]]()
  #g.node_attrs = tables.initTable[AttrKey, tables.TableRef[Node, Attribute]]()
  #g.edge_attrs = tables.initTable[AttrKey, tables.TableRef[Edge, Attribute]]()

proc newDiGraph*(): ref DiGraph =
  ## A directed graph.
  new(result)
  initDiGraph(result)

proc newBasicGraph*(): ref BasicGraph =
  ## Implemented as a directed graph with redundant edges.
  new(result)
  initDiGraph(result)

proc len*(g: ref DiGraph): int =
  return tables.len(g.adj)

proc has_node*(g: ref DiGraph, node: Node): bool =
  return tables.contains(g.adj, node)

proc contains*(g: ref DiGraph, node: Node): bool =
  ## in/notin
  return g.has_node(node)

proc add_node*(g: ref DiGraph, i: Node): Node {.discardable.} =
  assert i != g.none()
  if not tables.contains(g.adj, i):
    g.adj[i] = sets.HashSet[Node]()
    sets.init(g.adj[i])
  return i

proc remove_node*(g: ref DiGraph, u: Node) =
  assert u in g
  for v in sets.items(g.adj[u]):
    g.adj[v].excl(u)
  g.adj.del(u)
  #for attr_table in tables.values(g.node_attrs):
  #  tables.del(attr_table, u)

proc clear*(g: ref DiGraph) =
  tables.clear(g.adj)
  #tables.clear(g.node_attrs)
  #tables.clear(g.edge_attrs)

proc has_edge*(g: ref DiGraph, u, v: Node): bool =
  return (u in g) and (v in g) and (v in g.adj[u])

proc contains*(g: ref DiGraph, edge: Edge): bool =
  ## in/notin
  return g.has_edge(edge.u, edge.v)

proc add_edge*(g: ref DiGraph, u, v: Node) =
  echo format(" graph.add_edge($#, $#)", u, v)
  g.add_node(u)
  g.add_node(v)
  g.adj[u].incl(v)

proc add_edge*(g: ref BasicGraph, u, v: Node) =
  echo format(" basicgraph.add_edge($#, $#)", u, v)
  ## Add forward and backward edges.
  g.add_node(u)
  g.add_node(v)
  g.adj[u].incl(v)
  g.adj[v].incl(u)

proc add_path*(g: ref DiGraph, nodes: openarray[Node]) =
  var ready = false
  var u: Node
  for v in items(nodes):
    if ready:
      g.add_edge(u, v)
    else:
      ready = true
    u = v

proc add_path*(g: ref BasicGraph, nodes: openarray[Node]) =
  ## Add reverse path also.
  var ready = false
  var u: Node
  for v in items(nodes):
    if ready:
      g.add_edge(u, v)
      g.add_edge(v, u)
    else:
      ready = true
    u = v

proc remove_edge*(g: ref DiGraph, u, v: Node) =
  ## Nodes remain in Graph.
  echo format(" graph.remove_edge($#, $#)", u, v)
  if (u notin g) or (v notin g):
    return
  g.adj[u].excl(v)
  #let edge = (u, v)
  #for attr_table in tables.values(g.edge_attrs):
  #  tables.del(attr_table, edge)

proc remove_edge*(g: ref BasicGraph, u, v: Node) =
  ## Nodes remain in Graph.
  echo format(" basicgraph.remove_edge($#, $#)", u, v)
  if (u notin g) or (v notin g):
    return
  g.adj[u].excl(v)
  g.adj[v].excl(u)
  #let edgeF = (u, v)
  #let edgeR = (v, u)
  #for attr_table in tables.values(g.edge_attrs):
  #  tables.del(attr_table, edgeF)
  #  tables.del(attr_table, edgeR)

proc number_of_selfloops*(g: ref DiGraph): int =
  var num_self_edges = 0
  for u in g.adj.keys():
    if u in g.adj[u]:
      num_self_edges += 1
  return num_self_edges

proc number_of_edges*(g: ref DiGraph): int =
  var num_edge_pairs = 0
  for u in g.adj.keys():
    num_edge_pairs += sets.len(g.adj[u])
  return num_edge_pairs

proc number_of_edges*(g: ref BasicGraph): int =
  # Avoid double-counting, as if non-directed. Raise exception if num_edge_pairs is odd.
  var num_edge_pairs = 0
  let num_self_edges = g.number_of_selfloops()
  for u in g.adj.keys():
    num_edge_pairs += sets.len(g.adj[u])
  assert 0 == (num_edge_pairs + num_self_edges) mod 2
  return (num_edge_pairs + num_self_edges) shr 1  # divide by 2

proc `$`*(e: Edge): string =
  return format("Edge($#, $#)", e.u, e.v)

proc `$`*(g: ref DiGraph): string =
  result = "{\l"
  var firstu = true
  for u, vs in tables.mpairs(g.adj):
    if not firstu:
      result &= ",\l"
    else:
      firstu = false
    result &= "  " & $u & ": ["
    var firstv = true
    for v in sets.items(vs):
      if not firstv:
        result &= ","
      else:
        firstv = false
      result &= $v
    #for v, weight in tables.pairs(vs):
    #  result &= $v & "(" & $weight & ") "
    result &= "]"
  result &= "\n}"

iterator nodes*(g: ref DiGraph): Node =
  for n in tables.keys(g.adj):
    yield n

iterator edges*(g: ref DiGraph): Edge =
  for u, vs in tables.pairs(g.adj):
    for v in sets.items(vs):
      yield (u, v)

iterator edges*(g: ref BasicGraph): Edge =
  # Skip half the bidi edges.
  for u, vs in tables.pairs(g.adj):
    for v in sets.items(vs):
      if u <= v:
        yield (u, v)

iterator predecessors*(g: ref DiGraph, v: Node): Node =
  for u in sets.items(g.adj[v]):
    yield u

iterator successors*(g: ref DiGraph, u: Node): Node =
  for v in sets.items(g.adj[u]):
    yield v


when isMainModule:
  block: # test BasicGraph
    var g = newBasicGraph()
    assert 1 notin g

    g.add_node(1)
    assert 1 in g

    assert (not g.has_edge(1, 2))

    g.add_edge(1, 2)
    assert g.has_edge(1, 2)
    assert g.has_edge(2, 1)

    g.add_edge(2, 3)
    assert g.has_edge(2, 3)
    assert g.has_edge(3, 2)

    g.remove_edge(3, 2)
    assert not g.has_edge(3, 2)
    assert not g.has_edge(2, 3)
    assert g.number_of_edges() == 1
    assert len(g) == 3
    assert g.has_node(1)

    g.remove_node(1)
    assert (not g.has_node(1))
    assert g.number_of_edges() == 0
    assert len(g) == 2

    g.clear()
    assert len(g) == 0

  block: # test DiGraph
    var g = newDiGraph()
    assert 1 notin g

    g.add_node(1)
    assert 1 in g

    assert (not g.has_edge(1, 2))

    g.add_edge(1, 2)
    assert g.has_edge(1, 2)
    assert not g.has_edge(2, 1)

    g.add_edge(2, 3)
    assert g.has_edge(2, 3)
    assert not g.has_edge(3, 2)
    g.add_edge(3, 2)
    assert g.has_edge(3, 2)
    assert g.number_of_edges() == 3

    g.remove_edge(3, 2)
    assert not g.has_edge(3, 2)
    assert g.has_edge(2, 3)
    assert g.number_of_edges() == 2
    g.remove_edge(2, 3)
    assert g.number_of_edges() == 1
    assert len(g) == 3
    assert g.has_node(1)

    g.remove_node(1)
    assert (not g.has_node(1))
    assert g.number_of_edges() == 0
    assert len(g) == 2

    g.add_edge(2, 3)
    assert g.number_of_edges() == 1
    assert len(g) == 2

    g.clear()
    assert len(g) == 0
    assert g.number_of_edges() == 0
