function [] = deleteMsgBox()
%DELETEMSGBOX Delete all the message boxes
%   [] = deleteBoxMsg()
boxesT = timerfind('Tag','box');
if ~isempty(boxesT)
    try
        close(boxesT(:).UserData); % close the box window
    catch
    end
    delete(boxesT)
end
end

