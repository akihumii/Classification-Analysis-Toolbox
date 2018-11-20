function selectedBursts = getrbboxData(h,onsetLocsRaw,offsetLocsRaw)

set(h,'ButtonDownFcn',{@OnClickAxes,onsetLocsRaw,offsetLocsRaw});

k = waitforbuttonpress();

switch k
    case 0
        selectedBursts = h.Parent.UserData;
    case 1
        key = get(gcf,'currentcharacter');
        switch key
            case 13
                selectedBursts = -1;
            otherwise
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

