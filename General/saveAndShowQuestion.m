function [answerSave, answerShow] = saveAndShowQuestion()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

prompt = 'Save figures? (y/n): ';
answerSave = input(prompt,'s');

prompt = 'Show figures? (y/n): ';
answerShow = input(prompt,'s');

end

