function box = popMsg(content)
%popMsg Pop the message box to show the popping content
%   box = popMsg(content)

box = msgbox(content);
pause(2)
delete(box)
disp(content)
disp(' ')

end

