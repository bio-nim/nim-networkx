# vim: sw=4 ts=4 sts=4 tw=0 et:
from ../../classes/wgraph import Node, successors, predecessors
from ../../classes/graph import none
from ../../util import raiseEx
from binaryheap import nil
from strutils import `%`, `format`
from sets import contains, toHashSet, incl
from tables import `[]=`, `[]`, contains
from hashes import nil

export `[]=`, `[]`, contains, none, format, toHashSet, incl

#type
    #IntNode* = int
    #Node* = concept n, m
    #    n == m is bool
    #Distance* = concept x, y, type T
    #    x + y is T
    #    x < y is bool
#type
#    Distance* = int #float64
#    GGraph* = concept g
#        #type Node = type(g.none())
#        #g.none() is Node
#        g.contains(Node) is bool
#        g.weight(Node, Node) is Distance # not used
#        # plus a few more constraints
#        #iterator successors*[Key](g: GraphRef[Key], u: Node): (Node, Key)
#        #g.successors[Key](Node): (Node, Key)

template generate_procs*(Graph, Distance, Node: typedesc) =
  ## We use a template to generate the procedures because
  ## I have had trouble with Concepts, and because generics
  ## would require too many parameters.

  type GGraph = (ref Graph)
  proc dijkstra_multisource(G: GGraph
        , sources: sets.HashSet[Node]
        , preds: ref tables.Table[Node, seq[Node]]
        , paths: ref tables.Table[Node, seq[Node]]
        , cutoff: Distance
        , target: Node
  ): tables.TableRef[Node, Distance] =
    ## Uses Dijkstra's algorithm to find shortest weighted paths
    ## sources : non-empty iterable of nodes
    ##  Starting nodes for paths. If this is just an iterable containing
    ##  a single node, then all paths computed by this function will
    ##  start from that node. If there are two or more nodes in this
    ##  iterable, the computed paths may begin from any one of the start
    ##  nodes.

    ##weight: function
    ##    Function with (u, v, data) input that returns that edges weight

    ##preds: dict of lists, optional(default=None)
    ##    dict to store a list of predecessors keyed by that node
    ##    If None, predecessors are not stored.

    ##paths: dict, optional (default=None)
    ##    dict to store the path list from source to each node, keyed by node.
    ##    If None, paths are not stored.

    ##target : node label, optional
    ##    Ending node for path. Search is halted when target is found.

    ##cutoff : integer or float, optional
    ##    Depth to stop the search. Only return paths with length <= cutoff.

    ## Returns
    ## -------
    ## distance : dictionary
    ##     A mapping from node to shortest distance to that node from one
    ##     of the source nodes.

    ## Notes
    ## -----
    ## The optional predecessor and path dictionaries can be accessed by
    ## the caller through the original pred and paths objects passed
    ## as arguments. No need to explicitly return pred or paths.

    #G_succ = G._succ if G.is_directed() else G._adj

    var dist = tables.newTable[Node, Distance]()  # dictionary of final distances
    var seen = tables.initTable[Node, Distance]()
    # fringe is heapq with 3-tuples (distance,c,node)
    # use the count c to avoid comparing nodes (may not be able to)
    #iterator count(): int {.closure.} =
    #    var i = 0
    #    while true:
    #        yield i
    #        inc(i)
    #echo "first:", count()
    #echo "2nd:", count()
    #echo "3rd:", count()
    var count: int = 0
    type mytuple = tuple[d: Distance, c: int, v: Node]
    proc mytuple_cmp(x, y: mytuple): int =
        if x.d != y.d: return system.cmp(x.d, y.d)
        if x.c != y.c: return system.cmp(x.c, y.c)
        return system.cmp(x.v, y.v)
    var fringe: binaryheap.Heap[mytuple] = binaryheap.newHeap[mytuple](mytuple_cmp)
    for source in sets.items(sources):
        seen[source] = 0
        binaryheap.push(fringe, (0.Distance, count, source))
        inc(count)
    while binaryheap.size(fringe) > 0:
        let (d, _, v) = binaryheap.pop(fringe)
        if v in dist:
            continue  # already searched this node.
        dist[v] = d
        if v == target:
            break
        for w, cost in G.successors(v):
            #if cost == 0.Distance:
            #    continue
            let vw_dist = dist[v] + cost
            if vw_dist > cutoff:
                continue
            if w in dist:
                if vw_dist < dist[w]:
                    raiseEx("Contradictory paths found: negative weights?")
            elif w notin seen or vw_dist < seen[w]:
                seen[w] = vw_dist
                binaryheap.push(fringe, (vw_dist, count, w))
                inc(count)
                if paths != nil:
                    paths[w] = paths[v] & @[w]
                if preds != nil:
                    preds[w] = @[v]
            elif vw_dist == seen[w]:
                if preds != nil:
                    preds[w].add(v)

    # The optional predecessor and path dictionaries can be accessed
    # by the caller via the pred and paths objects passed as arguments.
    ##echo "dijkstra_multisource dist:", $dist
    return dist

  proc multi_source_dijkstra_foo*(G: GGraph
    , sources: sets.HashSet[Node]
    , cutoff: Distance
    ): (tables.TableRef[Node, Distance], tables.TableRef[Node, seq[Node]]) =
    ## Find shortest weighted paths and lengths from a given set of source nodes.
    assert 0 != sets.len(sources), "sources must not be empty"
    var preds = tables.newTable[Node, seq[Node]]()  # dict of predecessors
    var paths = tables.newTable[Node, seq[Node]]()  # dictionary of paths
    for s in sets.items(sources):
        paths[s] = @[s]
    let dist = dijkstra_multisource(G
            , sources
            , preds=nil #preds
            , paths=paths
            , cutoff=cutoff
            , target=G.none()
    )
    return (dist, paths)

  proc multi_source_dijkstra*(G: GGraph
    , sources: sets.HashSet[Node]
    , target: Node
    , cutoff: Distance
    ): (Distance, seq[Node]) =
    ## Find shortest weighted paths and lengths from a given set of source nodes
    ## to a specific target node.
    assert G.none() != target
    var zero: Distance
    if target in sources:
        return (zero, @[target])
    let (node2dist, node2path) = multi_source_dijkstra_foo(G, sources, cutoff)
    try:
        return (node2dist[target], node2path[target])
    except KeyError:
        raiseEx("No path to {}.".format(target))

  proc single_source_dijkstra*(G: GGraph
    , source: Node
    , target: Node
    , cutoff: Distance
    ): (Distance, seq[Node]) =
    ## Find shortest weighted paths and lengths from a source node.

    ## Compute the shortest path length between source and all other
    ## reachable nodes for a weighted graph.
    return multi_source_dijkstra(G, [source].toHashSet(), target, cutoff=cutoff)

  proc dijkstra_path*(G: GGraph
    , source, target: Node
    , cutoff: Distance = Distance.high
    ): seq[Node] =
    ## Returns the shortest weighted path from source to target in G.

    ## Uses Dijkstra's Method to compute the shortest weighted path
    ## between two nodes in a graph.
    assert G.none() != target
    let (length, path) = single_source_dijkstra(G, source, target, cutoff)
    return path

when isMainModule:

    # Generate the procs we need.
    generate_procs(wgraph.Graph[int], int, wgraph.Node)

    # test weighted directed Graph
    block:
        let g = wgraph.newGraph[int]()
        wgraph.add_path(g, 5, [1.Node, 2.Node, 9.Node])
        wgraph.add_path(g, 4, [1.Node, 3.Node, 7.Node, 9.Node])
        let path = dijkstra_path(g, 1.Node, 9.Node, Node.high)
        assert len(path) == 3
    block:
        let g = wgraph.newGraph[int]()
        wgraph.add_path(g, 5, [1.Node, 2.Node, 9.Node])
        wgraph.add_path(g, 3, [1.Node, 3.Node, 7.Node, 9.Node])
        let path = dijkstra_path(g, 1.Node, 9.Node, Node.high)
        assert len(path) == 4
