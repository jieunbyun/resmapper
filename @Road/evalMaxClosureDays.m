function roads = evalMaxClosureDays( roads )

for ii = 1:length(roads)
    iRoad = roads(ii);

    iAllClosureDays = [iRoad.closureDays_damage(:).'; iRoad.closureDays_building(:).'; iRoad.closureDays_overpass(:).'];
    iMaxClosureDays = max( iAllClosureDays );

    roads(ii).closureDays = iMaxClosureDays;
end