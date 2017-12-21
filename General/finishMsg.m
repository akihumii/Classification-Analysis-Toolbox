function [] = finishMsg()
%finishMsg Pop the message box to show all the processes have finished...
%   finishMsg()

finishMsg = msgbox('Finished all prcoesses...');
pause(2)
delete(finishMsg)
display('Finished all processes...')

end

