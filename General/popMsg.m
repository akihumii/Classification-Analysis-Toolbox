function popMsg(content)
%popMsg Pop the message box to show the popping content
%   [] = popMsg(content)
if usejava('jvm')  % only run when Matalab GUI is used without using -nodisplay nor -nojvm
    warning('off','all')
    deleteMsgBox(); % delete all the opened messge boxes
    
    timeClose = 5; % auto close the window once this timing has passed
    t = timer;
    set(t,'Tag','box');
    set(t,'StartFcn', {@startTimerFcn, content});
    set(t,'TimerFcn', @runTimerFcn);
    set(t,'StartDelay', timeClose);
    set(t,'StopFcn', @stopTimerFcn);
    set(t,'Tag','box');
    
    start(t)
end
disp(content)
disp(' ')
end

function startTimerFcn(obj,~,content)
box = msgbox(content);
try
    if isequal(content,'Finished...')
        playSound('gong',20);
    end
catch
end
set(obj,'UserData',box);
end

function runTimerFcn(~,~)
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
