%Get a Recording
recObj = audiorecorder
disp('Start speaking.')
recordblocking(recObj, 2);
disp('End of Recording.');
y = getaudiodata(recObj);
fs = 8000;

% Use Google API
speechObject = speechClient('Google','languageCode','en-US','maxAlternatives',3);
%[y,fs] = audioread('randoAudio.wav');
tableOut = speech2text(speechObject,y(:,1),fs)
words = table2struct(tableOut);
words.TRANSCRIPT = erase(words.TRANSCRIPT, '.')
words.TRANSCRIPT = erase(words.TRANSCRIPT, '?')
words.TRANSCRIPT = erase(words.TRANSCRIPT, '!')

% String Comparison to Action
if (strcmpi(words.TRANSCRIPT,'descend') || strcmpi(words.TRANSCRIPT,'fall') || strcmpi(words.TRANSCRIPT,'go down'))
    val = 31
elseif (strcmpi(words.TRANSCRIPT,'rise') || strcmpi(words.TRANSCRIPT,'ascend') || strcmpi(words.TRANSCRIPT,'climb') || strcmpi(words.TRANSCRIPT,'go up') )
    val = 30
elseif (strcmpi(words.TRANSCRIPT,'forward') || strcmpi(words.TRANSCRIPT,'go') || strcmpi(words.TRANSCRIPT,'go forwards'))
    val = 119
elseif (strcmpi(words.TRANSCRIPT,'go backwards.') || strcmpi(words.TRANSCRIPT,'reverse') || strcmpi(words.TRANSCRIPT,'go back'))
    val = 115
elseif (strcmpi(words.TRANSCRIPT, 'left'))
    val = 97
elseif (strcmpi(words.TRANSCRIPT, 'right'))
    val = 100
end
% Do Task A
