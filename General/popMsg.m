function box = popMsg(content)
%popMsg Pop the message box to show the popping content
%   [] = popMsg(content)

timeClose = 10; % auto close the window once this timing has passed
t = timer;
set(t,'StartFcn', {@startTimerFcn, content});
set(t,'TimerFcn', {@runTimerFcn, content});
set(t,'StartDelay', timeClose);
set(t,'StopFcn', {@stopTimerFcn, t});

start(t)
box = t.UserData;
end

function startTimerFcn(obj,~,content)
box = msgbox(content);
set(obj,'UserData',box);
end

function runTimerFcn(~,~,content)
disp(content)
end

function stopTimerFcn(obj,~,t)
box = obj.UserData;
if exist('box', 'var')
    delete(box);
    clear('box');
end
delete(t)
end
