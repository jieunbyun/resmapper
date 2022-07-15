classdef Road
    
    properties
        GIS_ID;
        isBridge;
        isMajor;
        length; % m
        structType;
        nodePair;
        district;
        overpasses;

        damageStates;
        recoveryDays;
        closureDays_damage;
        closureDays_building;
        closureDays_overpass;
        closureDays;
    end

    methods
        
        function road = Road( GIS_ID, isBridge, isMajor, length, structType, nodePair, district, overpasses, damageStates, recoveryDays, ...
                closureDays_damage, closureDays_building, closureDays_overpass, closureDays)
            if nargin > 0
                road.GIS_ID = GIS_ID;

                if nargin > 1
                    if (isBridge < 0 ) || (isBridge > 1)
                        error( 'isBridge must be either 1 (bridge) or 0 (paved road).' )
                    else
                        road.isBridge = isBridge;
                    end

                    if nargin > 2
                        if (isMajor < 0 ) || (isMajor > 1)
                            error( 'isMajor must be either 1 (major road) or 0 (minor road).' )
                        else
                            road.isMajor = isMajor;
                        end

                        if nargin > 3
                            road.length = length;
    
                            if nargin > 4
                                road.structType = structType;
    
                                if nargin > 5
                                    if length(nodePair) ~= 2
                                        error('A road must correspond to exactly two nodes.')
                                    else
                                        road.nodePair = nodePair(:).';
                                    end

                                    if nargin > 6
                                        if ~isscalar( district )
                                            error( 'A road must correspond to exactly one district.' )
                                        else
                                            road.district = district;
                                        end

                                        if nargin > 7
                                            road.overpasses = overpasses;

                                            if nargin > 8
                                                road.damageStates = damageStates;
    
                                                if nargin > 9 
                                                    road.recoveryDays = recoveryDays;
    
                                                    if nargin > 10
                                                        road. closureDays_damage = closureDays_damage;
    
                                                        if nargin > 11
                                                            road.closureDays_building = closureDays_building;
    
                                                            if nargin > 12
                                                                road.closureDays_overpass = closureDays_overpass;

                                                                if nargin > 13
                                                                    road.closureDays = closureDays;
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

    end

end