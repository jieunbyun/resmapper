function roads = addOverpasses( roads, overpassJoin_array )

[gisId2arrayId, gisId_min] = convertGisId2arrayId( roads );

for iJoinInd = 1:size(overpassJoin_array, 1)
    iRoad_gisId = overpassJoin_array(iJoinInd, 1);
    iOverpass_gisId = overpassJoin_array(iJoinInd, 2);

    iRoad_arrayId = gisId2arrayId( iRoad_gisId-gisId_min+1 );
    iOverpass_arrayId = gisId2arrayId( iOverpass_gisId-gisId_min+1 );

    if ~ismember( iOverpass_arrayId, roads(iRoad_arrayId).overpasses )
        roads(iRoad_arrayId).overpasses = [roads(iRoad_arrayId).overpasses iOverpass_arrayId];
    end
end