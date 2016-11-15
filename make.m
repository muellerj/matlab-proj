function make(option, varargin)
%MAKE
%
% Project specific Makefile. Executes common tasks depending on the context and
% the `option` passed by parameter:
%
%   make [option]

  % Add library paths
  addpath(genpath([rootpath '/lib']));
  addpath(genpath([rootpath '/spec']));
  addpath(genpath([rootpath '/mdl']));

  if nargin < 1
    make('spec');
  else
    switch(option)
      case 'spec'
        run_specs(varargin{:});
      otherwise
        error(['Unkown option ' option])
    end
  end
end

function x = rootpath()
  x = char(regexp(mfilename('fullpath'), '(.*)[\\\/]make', 'tokens', 'once'));
end
