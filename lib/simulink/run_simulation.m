function simout = run_simulation(modelname, varargin)
% Run model MODELNAME with parameters/inputs passed in as key/value pairs.
% If the same key/value pair is repeated, the first one wins.

  if any(strcmpi(varargin, 'debug'))
    debug = true;
    varargin(strcmpi(varargin, 'debug')) = [];
  else
    debug = false;
  end

  if not(mod(numel(varargin), 2) == 0)
    error('Simulation parameters must come in pairs!');
  end

  if not(any(strcmp(varargin, 'time')))
    error('Simulation parameters must contain a time vector');
  end

  % Create test harness
  time = varargin{find(strcmp(varargin, 'time'))+1};
  [testharnessname, inputnames] = create_testharness(modelname, time);

  % Assign inputs/parameters
  for vidx = numel(varargin):-2:1
    assignin('base', varargin{vidx-1}, varargin{vidx});
  end

  % Stub non-assigned inputs
  stub_inputs = setdiff(inputnames, varargin(1:2:end));
  for sidx = 1:numel(stub_inputs)
    assignin('base', stub_inputs{sidx}, benign_signal_builder(stub_inputs{sidx}, max(time)));
  end

  % Run test harness
  simout_raw = sim(testharnessname, 'ReturnWorkspaceOutputs', 'on');

  % Convert output to sensible struct
  outvars = get(simout_raw);
  simout = struct();
  for vidx = 1:numel(outvars)
    simout.(outvars{vidx}) = get(simout_raw, outvars{vidx});
  end

  % Add time vector
  simout.time = time;

  % Debug model if required
  if debug, keyboard; end

  % Close model
  bdclose(testharnessname);

  % Clear simulation inputs from base workspace
  for vidx = 1:2:numel(varargin)
    evalin('base', ['clear ' varargin{vidx}]);
  end

  % Clear stub inputs from base workspace
  for sidx = 1:2:numel(stub_inputs)
    evalin('base', ['clear ' stub_inputs{sidx}]);
  end

end
