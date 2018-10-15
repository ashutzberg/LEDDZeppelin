classdef speechClient <  dynamicprops
    % speechClient Interface with 3rd party Speech Recognition APIs
    %
    % clientObject = speechClient(apiName) creates a speechClient object to
    % interface with a 3rd party API specified by apiName. Valid API names
    % include ‘Google’,’IBM’, and ‘Microsoft’.
    %
    % clientObject = speechClient (apiName,'PropertyName','PropertyValue')
    % specifies additional properties used by the 3rd party API.
    % Unspecified properties use default values.
    %
    % Valid property names and values depend on the 3rd party API. See the
    % documentation for valid property names and values.
    %
    %
    % Copyright 2017 The MathWorks, Inc.