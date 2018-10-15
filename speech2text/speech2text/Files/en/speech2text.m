function tableOut = speech2text(connection , y , fs , varargin)
    % speech2text Transcribe speech signal to text
    %
    % The speech2text function enables you to interface with 3rd party
    % cloud-based speech-to-text APIs through MATLAB. Supported 3rd party
    % Speech Recognition APIs include: Google, IBM, Microsoft.
    %
    % To use the speech2text function, set up an account with the third
    % party API as outlined in the documentation.
    %
    % TEXT = speech2text(clientObject,SPEECH,FS) transcribes the SPEECH,
    % sampled at FS Hertz, to text by passing the data to the clientObject. The
    % clientObject is an interface to a third-party API, and is an object of
    % the speechClient class. The output TEXT is returned as a table that
    % contains the transcription and confidence metrics. Some APIs
    % provide additional outputs and are also returned in the table.
    %
    % TEXT = speech2text(..., 'HTTPTimeOut',TIMEOUT) specify the TIMEOUT 
    % value in seconds to wait for initial server connection
    %
    % Copyright 2017 The MathWorks, Inc.