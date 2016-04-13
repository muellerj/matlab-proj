function sigout = signal_builder(type, varargin)
%SIGNAL_BUILDER
%
% Build signals for use in test cases. The function is meant to provide a standardised
% interface, such that tests can be understood as much as possible without the use of
% plots.
%
%   signal_builder(TYPE, [KEY1, VALUE1, ...]);
%
% Possible options for the key/value pairs (with default values) are:
%
%   NAME              EXPLANATION                         DEFAULT VALUE
%   --------------------------------------------------------------------ma------
%   Ts                Sample time                         1e-3
%   Tmax              Maximum value for time vector       5
%   Tstep             Time index, when step happens       1
%   Frequency         Frequency of sine [Hz]              3
%   Value             Signal value                        1
%   x0                Initial value for step fct          0
%   xN                Final value for step fct            1
%   Width             Width or rectangular pulse [s]      1
%   DataType          Data type of the output             'double'
%
% The first key/value pair wins, all subsequent pairs are discarded!
%
% Author:
%   Jonas Mueller, EA-252

% Parse parameters
if nargin > 1 && mod(nargin-1, 2) ~= 0
  error('Wrong number of parameters');
end

% Set default options
options           = struct();
options.Ts        = 1e-3;
options.Tmax      = 5;
options.Tstep     = 1;
options.Frequency = 3;
options.Value     = 1;
options.x0        = 0;
options.xN        = 1;
options.Width     = 1;
options.DataType = 'double';

% ... and let the user override them (go backwards to let first pair win)
for vidx = numel(varargin)-1:-2:1
  if any(strcmp(varargin{vidx}, fieldnames(options)))
    eval(['options.' varargin{vidx} ' = varargin{' num2str(vidx+1) '};']);
  else
    error(['Invalid parameter: ' varargin{vidx}]);
  end
end

% Build time vector (row-vector)
time = (0:options.Ts:options.Tmax)';

switch(type)
  case 'time'
    sigout = time;
  case 'const'
    sigout = options.Value*ones(size(time));
  case 'step'
    sigout = options.xN*ones(size(time));
    sigout(time < options.Tstep) = options.x0;
  case 'rectpuls'
    sigout = double(rectpuls(time - options.Tstep - options.Width/2, options.Width));
  case 'sine'
    sigout = options.Value*sin(time*2*pi*options.Frequency);
  otherwise
    error(['Unknown signal type: ' type]);
end

% Convert data type if required
if not(strcmp(options.DataType, 'double'))
  sigout = feval(options.DataType, sigout);
end

end
