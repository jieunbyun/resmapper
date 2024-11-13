function roads = evalNClosureDaysByOverpass( roads, closureRatioToRecoveryDays_overpass )

nRoad = length(roads);

for iRoadInd = 1:nRoad
    iOverpasses = roads(iRoadInd).overpasses;
    if isempty( iOverpasses )
        iClosureDays = zeros( size( roads(iRoadInd).recoveryDays ) );
    else
        iClosureDays = arrayfun( @(x) x.recoveryDays, roads(iOverpasses), 'UniformOutput', false );
        iClosureDays = iClosureDays(~cellfun('isempty', iClosureDays));
        iClosureDays = max(iClosureDays, [], 1);
        iClosureDays = ceil( closureRatioToRecoveryDays_overpass * iClosureDays );
    end

    roads(iRoadInd).closureDays_overpass = iClosureDays;

end