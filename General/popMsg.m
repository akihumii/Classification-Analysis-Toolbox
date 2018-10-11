function popMsg(content)
%popMsg Pop the message box to show the popping content
%   [] = popMsg(content)
warning('off','all')
boxesT = timerfind('Tag','box');
if ~isempty(boxesT)
    close(boxesT(:).UserData); % close the box window
    delete(boxesT)
end

timeClose = 3000; % auto close the window once this timing has passed
t = timer;
set(t,'Tag','box');
set(t,'StartFcn', {@startTimerFcn, content});
set(t,'TimerFcn', {@runTimerFcn, content});
set(t,'StartDelay', timeClose);
set(t,'StopFcn', @stopTimerFcn);
set(t,'Tag','box');

start(t)
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
