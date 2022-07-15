function districts = addGMId(districts, GMs, districtGmJoin_array)

% Get pointer from GM GIS ID to array ID (for computation efficiency)
gmGisIds = arrayfun( @(x) x.GIS_ID, GMs );
gmGisId_min = min(gmGisIds);
gmGisId_max = max(gmGisIds);
gmId_gis2array = zeros( (gmGisId_max-gmGisId_min)+1, 1 ); % GIS IDs can start from 0.

nGM = length(GMs);
for iGMArrayId = 1:nGM
    iGMGisId = GMs(iGMArrayId).GIS_ID;
    gmId_gis2array( iGMGisId-gmGisId_min+1 ) = iGMArrayId;
end

% Match each district to a GM region
nDistrict = length( districts );
for iDistrictIndex = 1:nDistrict

    iDistrict = districts( iDistrictIndex );
    iDistrict_gisId = iDistrict.GIS_ID;

    iGM_gisId = districtGmJoin_array( districtGmJoin_array( :, 1 ) == iDistrict_gisId, 2 );
    iGmArrayIds = gmId_gis2array( iGM_gisId-gmGisId_min+1 );
    if length( iGmArrayIds ) > 2
        error( 'A district must be associated with exactly one GM region.' )
    else
        districts(iDistrictIndex).GM_ID = iGmArrayIds;
    end

end