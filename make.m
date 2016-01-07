function make(option, varargin)
%MAKE
%
% Project specific Makefile. Executes common tasks depending on the context and
% the `option` passed by parameter:
%
%   make [option]

  % Add library paths
  addpath(genpath([projectpath '/lib']));
  addpath(genpath([projectpath '/spec']));

  if nargin < 1
    make('spec');
  else
    switch(option)
      case 'spec'
        run_specs;
      otherwise
        error(['Unkown option ' option])
    end
  end
end

function ppath = projectpath()
  ppath = regexp(mfilename('fullpath'), '(.*)[\\\/]make', 'tokens');
  ppath = ppath{1}{1};
end
