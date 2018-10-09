function box = popMsg(content)
%popMsg Pop the message box to show the popping content
%   [] = popMsg(content)
warning('off','all')
delete(timerfind('Tag','box'))

timeClose = 5; % auto close the window once this timing has passed
boxT = timer;
set(boxT,'StartFcn', {@startTimerFcn, content});
set(boxT,'TimerFcn', {@runTimerFcn, content});
set(boxT,'StartDelay', timeClose);
set(boxT,'StopFcn', @stopTimerFcn);
set(boxT,'Tag','box');

start(boxT)
box = boxT.UserData;
end

function startTimerFcn(obj,~,content)
box = msgbox(content);
set(obj,'UserData',box);
end

function runTimerFcn(~,~,content)
disp(content)
end

function stopTimerFcn(obj,~)
try
    box = obj.UserData;
    if exist('box', 'var')
        delete(box);
        clear('box');
    end
    delete(obj)
catch
end
end
