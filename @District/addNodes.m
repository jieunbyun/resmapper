function districts = addNodes( districts, nodes, nodeDistrictJoin_array )

[nodeGisId2arrayId, nodeGisId_min] = convertGisId2arrayId( nodes );

for iDistInd = 1:length(districts)
    iDistGisId = districts(iDistInd).GIS_ID;
    iNodeGisId = nodeDistrictJoin_array( nodeDistrictJoin_array(:,2) == iDistGisId, 1 );

    iNodeArrayId = nodeGisId2arrayId( iNodeGisId - nodeGisId_min + 1 );
    districts(iDistInd).nodes_ID = iNodeArrayId(:).';
end
