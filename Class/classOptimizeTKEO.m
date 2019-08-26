classdef classOptimizeTKEO < matlab.System
    %CLASSOPTIMIZETKEO To be used in dataClassificationPreparation
    %   It's for optimize TKEO parameters
    
    properties
        loss
        lossOrig
        deltaLoss
        deltaLossAll = ones(3,4)
        TKEOParametersChange
        optimizeFlag = 1
        Mdl
        repCount = 1
        changeIndex = [1,1];
        change
        timetaken
    end
    
    methods
        function parameters = randomizeTKEOParameters(obj, parameters)
            parameters.TKEOStartConsecutivePoints = multiplyValues(parameters.TKEOStartConsecutivePoints);
            [parameters.TKEOStartConsecutivePoints, obj.change(1,:)] = changeValues(parameters.TKEOStartConsecutivePoints, parameters.learningRate(1));
            
            parameters.TKEOEndConsecutivePoints = multiplyValues(parameters.TKEOEndConsecutivePoints);
            [parameters.TKEOEndConsecutivePoints, obj.change(2,:)] = changeValues(parameters.TKEOEndConsecutivePoints, parameters.learningRate(2));
            
            parameters.threshStdMult = multiplyValues(parameters.threshStdMult);
            [parameters.threshStdMult, obj.change(3,:)] = changeValues(parameters.threshStdMult, parameters.learningRate(3));
        end

        function parameters = editTKEOParameters(obj, parameters)
            updateValue = sign(obj.deltaLoss) * sign(obj.change(obj.changeIndex(1,1), obj.changeIndex(1,2))) * ...
                (floor(parameters.learningRate(obj.changeIndex(1,1)) * ...
                sigmf(abs(obj.deltaLoss/obj.lossOrig) * 100, [0.1, 50])) + 1);
            % if sign(updateValue) ~= sign(obj.change(obj.changeIndex(1,1), obj.changeIndex(1,2)))
            %     updateValue = updateValue + sign(updateValue) * abs(obj.change(obj.changeIndex(1,1), obj.changeIndex(1,2)));
            % end
            
            obj.change(obj.changeIndex(1,1), obj.changeIndex(1,2)) = updateValue;
            switch obj.changeIndex(1,1)
                case 1
                    parameters.TKEOStartConsecutivePoints(1, obj.changeIndex(1,2)) = ...
                        parameters.TKEOStartConsecutivePoints(1, obj.changeIndex(1,2)) + updateValue;
                    fprintf('channel %d | TKEO starting: %d\n', obj.changeIndex(1,2), parameters.TKEOStartConsecutivePoints(1, obj.changeIndex(1,2)));
                case 2
                    parameters.TKEOEndConsecutivePoints(1, obj.changeIndex(1,2)) = ...
                        parameters.TKEOEndConsecutivePoints(1, obj.changeIndex(1,2)) + updateValue;
                    fprintf('channel %d | TKEO end: %d\n', obj.changeIndex(1,2), parameters.TKEOEndConsecutivePoints(1, obj.changeIndex(1,2)));
                case 3
                    parameters.threshStdMult(1, obj.changeIndex(1,2)) = ...
                        parameters.threshStdMult(1, obj.changeIndex(1,2)) + updateValue;
                    fprintf('channel %d | thresh mult: %d\n', obj.changeIndex(1,2), parameters.threshStdMult(1, obj.changeIndex(1,2)));
            end
        end
        
        function getSVMLoss(obj, clfp, parameters)
            featuresAll = [];
            classAll = [];
            for i = 1:length(clfp)
                features = struct2cell(clfp(i,1).features);
                features = horzcat(features{parameters.featuresID});
                featuresAll = [featuresAll; features];
                
                class = i * ones(size(features,1),1);
                classAll = [classAll; class];
            end
            obj.Mdl = svmClassification(featuresAll, classAll, []);
            obj.loss = obj.Mdl.oosLoss;  % update loss
        end
        
        function updateOptimizeFlag(obj, parameters)
            obj.deltaLoss = obj.lossOrig-obj.loss;  % check delta loss
            obj.lossOrig = obj.loss;
            fprintf('Optimizing %d,%d  | Run %d | current loss: %.4f | delta loss: %.4f...\n',...
                obj.changeIndex(1,1), obj.changeIndex(1,2), obj.repCount, obj.loss, obj.deltaLoss);
            obj.deltaLossAll(obj.changeIndex(1,1), obj.changeIndex(1,2)) = obj.deltaLoss;
            deltaLossChecking = abs(obj.deltaLossAll) > parameters.deltaLossLimit;
            obj.optimizeFlag = obj.loss > parameters.lossLimit && any(deltaLossChecking(:));
        end
        
        function saveTKEOParameter(obj, parameters)
            tkeoTable = table(parameters.threshStdMult, parameters.TKEOStartConsecutivePoints, parameters.TKEOEndConsecutivePoints,obj.loss,obj.deltaLoss,...
                'VariableNames', {'threshStdMult','TKEOStartConsecutivePoints','TKEOEndConsecutivePoints','loss','deltaLoss'});
            obj.TKEOParametersChange = [obj.TKEOParametersChange; tkeoTable];
        end
        
        function updateCounter(obj, parameters)
            if obj.repCount == 10 || abs(obj.deltaLoss) < parameters.deltaLossLimit
                obj.repCount = 1;
                
                if obj.changeIndex(1,2) == 4
                    if obj.changeIndex(1,1) == 3
                        obj.changeIndex(1,1) = 1;
                    else
                        obj.changeIndex(1,1) = obj.changeIndex(1,1) + 1;
                    end
                    obj.changeIndex(1,2) = 1;
                else
                    obj.changeIndex(1,2) = obj.changeIndex(1,2) + 1;
                end
            else
                obj.repCount = obj.repCount + 1;
            end
        end
        
        function parameters = getLowestLoss(obj, parameters)
            locs = find(obj.TKEOParametersChange.loss == min(obj.TKEOParametersChange.loss));
            parameters.TKEOStartConsecutivePoints = obj.TKEOParametersChange.TKEOStartConsecutivePoints(locs,:);
            parameters.TKEOEndConsecutivePoints = obj.TKEOParametersChange.TKEOEndConsecutivePoints(locs,:);
            parameters.threshStdMult = obj.TKEOParametersChange.threshStdMult(locs,:);
        end
    end
end

