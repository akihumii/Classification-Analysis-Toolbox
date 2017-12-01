classdef classifier
    %classifier Perform classification
    %   function clf = classifier(name)
    %   function classification(clf, grouping)
    
    properties
        name
        result
    end
    
    methods
        function clf = classifier(name)
            if nargin > 0
                clf.name = name;
            end
        end
        
       function clf = classification(clf, trials)
            clf.result = classification(trials); 
        end
    end
    
end

