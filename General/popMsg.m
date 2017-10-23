function box = popMsg(title, content)
%popMsg Summary of this function goes here
%   Detailed explanation goes here
box = msgbox(content, title);
set(box,'Units','Normalized','Position',[0.42, 0.47, 0.13, 0.08])
end

