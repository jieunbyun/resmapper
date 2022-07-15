function roadsClearPriority = evalRoadsClearPriority( roads, nodes )

tails = arrayfun( @(x) x.nodePair(1), roads );
heads = arrayfun( @(x) x.nodePair(2), roads );

G = graph( tails, heads );
clearStartNodes = find( arrayfun( @(x) x.clearPriority == 1, nodes ) );

nClearStartNodes = length( clearStartNodes );
nNode = length(nodes);
nodesPriorityForAllStartNodes = zeros( nNode, nClearStartNodes );
for iNodeIndex = 1:nClearStartNodes
    iNodeId = clearStartNodes( iNodeIndex );
    iNodeIdList = bfsearch( G, iNodeId );
    iNodeIdNotInList = setdiff( (1:nNode)', iNodeIdList);
    iNodeIdList = [iNodeIdList; iNodeIdNotInList];
    [~,iNodesPriority] = sort( iNodeIdList );
    nodesPriorityForAllStartNodes( :, iNodeIndex ) = iNodesPriority;
end

nodesPriorityForAllStartNodes = min( nodesPriorityForAllStartNodes, [], 2 );
[~, nodesClearPriority] = sort( nodesPriorityForAllStartNodes );

nRoad = length(roads);
roadIdsInLoop = ( 1:nRoad ).'; roadsClearPriority = [];
nodePairIdArrayInLoop = [tails heads];
for iNodeIndex = 2:length( nodesClearPriority )
    iNodeIds = nodesClearPriority( 1:iNodeIndex );
    iRoadIndicesInLoop = find( ismember( nodePairIdArrayInLoop( :, 1 ), iNodeIds ) & ismember( nodePairIdArrayInLoop( :, 2 ), iNodeIds ) );
    roadsClearPriority = [roadsClearPriority; roadIdsInLoop(iRoadIndicesInLoop)];
    
    nodePairIdArrayInLoop( iRoadIndicesInLoop, : ) = [];
    roadIdsInLoop( iRoadIndicesInLoop ) = [];
end
    

    