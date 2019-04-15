# vim: sw=2 ts=2 sts=2 tw=0 et:
from ../../classes/graph import Node, contains, add_node, successors, predecessors, add_edge
from ../../classes/wgraph import add_edge
from ../../util import NetworkxError
import tables
from strutils import `%`, format
from "../../util" import raiseEx

type
  GGraph* = concept g
    contains(g, Node) is bool
    # plus a few more constraints

proc bidirectional_pred_succ(G: GGraph, source, target: Node):
        (tables.Table[Node,Node], tables.Table[Node,Node], Node) =
    ## Does BFS from both source and target; meets in the middle.
    ## Handles either directed or undirected.
    ## Returns (pred, succ, w) where
    ## pred is a dictionary of predecessors from w to the source, and
    ## succ is a dictionary of successors from w to the target.
  
    if target == source:
        return ({target: 0.Node}.toTable, {source: 0.Node}.toTable, source)
  
    # predecesssor and successors in search
    var pred = tables.initTable[Node,Node]()
    var succ = tables.initTable[Node,Node]()
    pred[source] = 0
    succ[target] = 0
  
    # initialize fringes, start with forward
    var forward_fringe = @[source]
    var reverse_fringe = @[target]
  
    while 0!=len(forward_fringe) and 0!=len(reverse_fringe):
        if len(forward_fringe) <= len(reverse_fringe):
            let this_level = forward_fringe
            forward_fringe = @[]
            for v in this_level:
                for w in G.successors(v):
                    if w notin pred:
                        forward_fringe.add(w)
                        pred[w] = v
                    if w in succ:  # path found
                        return (pred, succ, w)
        else:
            let this_level = reverse_fringe
            reverse_fringe = @[]
            for v in this_level:
                for w in G.predecessors(v):
                    if w notin succ:
                        succ[w] = v
                        reverse_fringe.add(w)
                    if w in pred:  # found path
                        return (pred, succ, w)
    raiseEx("NetworkXNoPath: No path between $# and $#.".format(source, target))

proc reverse*(s: var seq[Node]) =
  for i in 0 .. s.high div 2:
    system.swap(s[i], s[s.high - i])

proc bidirectional_shortest_path*(G: GGraph, source, target: Node): seq[Node]  =
    ## Returns a seq of nodes in a shortest path between source and target.
    if source notin G or target notin G:
        let msg = strutils.format(
            "Either source $# or target $# is not in G",
            source, target)
        raiseEx(msg)
  
    # call helper to do the real work
    var (pred, succ, w) = bidirectional_pred_succ(G, source, target)
  
    # build path from pred+w+succ
    var path = newSeq[Node](0)
    # from source to w
    while (w != 0):
        path.add(w)
        w = pred.getOrDefault(w)
    path.reverse()
    # from w to target
    w = succ.getOrDefault(path[path.high])
    while (w != 0):
        path.add(w)
        w = succ.getOrDefault(w)
  
    return path

proc shortest_path*(G: GGraph, source, target: Node): seq[Node]  =
    return bidirectional_shortest_path(G, source, target)


proc test_digraph_shortest_path(ctor: proc():GGraph) =
    # Directed Graph
    var i = ctor()
    i.add_node(1)
    i.add_edge(1, 2)
    assert @[1.Node,2.Node] == shortest_path(i, 1, 2)
    try:
      discard shortest_path(i, 2, 1)
      assert false, "DiGraph has 2->1, but not 1->2"
    except NetworkxError:
      discard
    i.add_edge(2, 1)
    assert @[2.Node,1.Node] == shortest_path(i, 2, 1)
    assert @[1.Node,2.Node] == shortest_path(i, 1, 2) # still here!
    i.add_edge(2.Node, 3.Node)
    assert @[1.Node,2.Node,3.Node] == shortest_path(i, 1, 3)
    assert @[2.Node,3.Node] == shortest_path(i, 2, 3)
    i.add_edge(3, 2)
    i.add_edge(3, 2)
    assert @[3.Node,2.Node,1.Node] == shortest_path(i, 3, 1)

proc test_shortest_path(ctor: proc():GGraph) =
  block:
    var i = ctor()
    # self-loop ignored for shortest path
    i.add_node(1)
    assert @[1.Node] == shortest_path(i, 1, 1)
    i.add_edge(1, 1)
    assert @[1.Node] == shortest_path(i, 1, 1)
  block:
    var i = ctor()
    i.add_node(1)
    i.add_edge(1, 2)
    i.add_edge(3, 2)
    assert @[1.Node,2.Node,3.Node] == shortest_path(i, 1, 3)
    assert @[2.Node,3.Node] == shortest_path(i, 2, 3)
    assert @[3.Node,2.Node,1.Node] == shortest_path(i, 3, 1)

when isMainModule:
  block:
    test_digraph_shortest_path(graph.newDiGraph)

  block:
    #test_shortest_path(intsetbased.newGraph)
    #test_shortest_path(simple_graph.newGraph)
    test_shortest_path(graph.newBasicGraph)

  block: # test weighted directed Graph
    let g = graph.newDiGraph()
    graph.add_path(g, [1.Node, 2.Node, 3.Node])
