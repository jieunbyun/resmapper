function roads = addDistrict( roads, districts, roadDistrictJoin_array )

% Get pointer from Node GIS ID to array ID (for computation efficiency)
districtGisIds = arrayfun( @(x) x.GIS_ID, districts );
districtGisId_min = min(districtGisIds);
districtGisId_max = max(districtGisIds);
districtId_gis2array = zeros( (districtGisId_max-districtGisId_min)+1, 1 ); % GIS IDs can start from 0.

nDistrict = length(districts);
for iDistArrayId = 1:nDistrict
    iNodeGisId = districts(iDistArrayId).GIS_ID;
    districtId_gis2array( iNodeGisId-districtGisId_min+1 ) = iDistArrayId;
end

% Match each road to a node pair
nRoad = length( roads );
nRoadMissingDistrict = 0;
for iRoadIndex = 1:nRoad

    iRoad = roads( iRoadIndex );
    iRoad_gisId = iRoad.GIS_ID;

    iDistrict_gisId = roadDistrictJoin_array( roadDistrictJoin_array( :, 1 ) == iRoad_gisId, 2 );
    if iDistrict_gisId-districtGisId_min+1 > length(districtId_gis2array)
        roads(iRoadIndex).district = -1;
        nRoadMissingDistrict = nRoadMissingDistrict+1;

    elseif isempty( iDistrict_gisId )
        roads(iRoadIndex).district = -1;
        nRoadMissingDistrict = nRoadMissingDistrict+1;

    else
        iDistrictArrayIds = districtId_gis2array( iDistrict_gisId-districtGisId_min+1 );
        if ~isscalar( iDistrictArrayIds )
            error( 'A road must lie in exactly one district.' )
        elseif ~iDistrictArrayIds
            roads(iRoadIndex).district = -1;
            nRoadMissingDistrict = nRoadMissingDistrict+1;
        else
            roads(iRoadIndex).district = iDistrictArrayIds(:).';
        end
    end

end

if nRoadMissingDistrict > 0
    warning( strcat( num2str(nRoadMissingDistrict), ' roads have no matching district (following analysis will assign a district randomly).') )
end