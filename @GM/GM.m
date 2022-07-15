classdef GM
    
    properties
        GIS_ID;
        Mw; % Moment magnitude
        PGA; % Peak ground acceleration (g)
        Sa1; % Spectral acceleration at period 1 sec. (g)
    end

    methods

        function gm = GM(GIS_ID, Mw, PGA, Sa1)
            if nargin > 0
                gm.GIS_ID = GIS_ID;
                if nargin > 1
                    gm.Mw = Mw;
    
                    if nargin > 2
                        gm.PGA = PGA;
    
                        if nargin > 3
                            gm.Sa1 = Sa1;
                        end
                    end
                end
            end
        end

    end

end