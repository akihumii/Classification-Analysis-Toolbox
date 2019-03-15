classdef bionicHand
    %BIONICHAND Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        hand
    end
    
    methods
        function obj = bionicHand(comPort)
            %BIONICHAND Construct an instance of this class
            %   Detailed explanation goes here
            obj.hand = serial(comPort, 'BaudRate', 19200);
            fopen(obj.hand);
        end
        
        function writeToHand(obj,input)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            fprintf(obj.hand, input);
        end
        
        function closeBionicHand(obj)
            fclose(obj.hand);
        end
    end
end

