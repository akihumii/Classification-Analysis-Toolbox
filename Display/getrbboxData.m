function selectedBursts = getrbboxData(h,onsetLocsRaw,offsetLocsRaw)
%SELECTEDBURSTS Click on the figure to send back the seclected bursts
% Input:    Left click to start selecting burst, if there is burst inside, the box
%           will turn into red color, otherwise there will be nothing happened.
%           After a red box appears, hit 'delete' button or right click to
%           delete the bursts. Otherwise nothing will be selected.
%           
%           Wheel button click or hit the 'enter' button will exit.
% 
% selectedBursts = getrbboxData(h,onsetLocsRaw,offsetLocsRaw)
set(h,'ButtonDownFcn',{@OnClickAxes,onsetLocsRaw,offsetLocsRaw});

k = waitforbuttonpress();

switch k
    case 0
        key = get(gcf,'SelectionType');
        switch key
            case 'alt' % right click
                selectedBursts = h.Parent.UserData;
            case 'extend' % wheel button
                selectedBursts = -1;
            otherwise
                selectedBursts = [];
        end
    case 1
        key = get(gcf,'CurrentCharacter');
        switch key
            case 13
                selectedBursts = -1;
            case 'z'
                zoom % zoom in / out
            case 'a'
                hP = pan; % pan / move the plot
                cn = hP.Enable;
                switch cn
                    case 'on'
                        pan off
                    case 'off'
                        pan xon
                    otherwise
                end
            case 'q'
                pan off
                zoom off
            otherwise
        end
        if ~exist('selectedBursts','var')
            selectedBursts = [];
        end
    otherwise
end

h.Parent.UserData = [];

end

function OnClickAxes( h, ~, onsetLocsRaw, offsetLocsRaw )

point1 = get(h,'CurrentPoint'); % corner where rectangle starts ( initial mouse down point )
rect_pos = rbbox;
point2 = get(h,'CurrentPoint'); % corner where rectangle stops ( when user lets go of mouse )

boundaryX = sort([point1(1,1),point2(1,1)]);
boundaryY = sort([point1(1,2),point2(1,2)]);

rectPos = [boundaryX(1), boundaryY(1), diff(boundaryX), diff(boundaryY)];
pBbox = rectangle('Position',rectPos,'EdgeColor','r');

selectedBursts = find(onsetLocsRaw > boundaryX(1) & offsetLocsRaw < boundaryX(2));

if ~isempty(selectedBursts)
    k = waitforbuttonpress();
    switch k
        case 0
            key = get(gcf, 'SelectionType');
            switch key
                case 'alt' % right click
                    h.Parent.UserData = selectedBursts;
                otherwise
                    disp('Nothing is selected...')
            end
        case 1
            key = get(gcf, 'CurrentCharacter');
            switch double(key)
                case 127 % delete key
                    h.Parent.UserData = selectedBursts;
                otherwise
                    disp('Nothing is selected...')
            end
        otherwise
            disp('Nothing is selected...')
    end
end

delete(pBbox);

end

