function [gisId2arrayId, gisId_min] = convertGisId2arrayId( objects )

gisIds = arrayfun( @(x) x.GIS_ID, objects );
gisId_min = min(gisIds);
gisId_max = max(gisIds);
gisId2arrayId = zeros( (gisId_max-gisId_min)+1, 1 ); % GIS IDs can start from 0.

nObject = length(objects);
for iArrayId = 1:nObject
    iGisId = objects(iArrayId).GIS_ID;
    gisId2arrayId( iGisId-gisId_min+1 ) = iArrayId;
end