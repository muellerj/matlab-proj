function simout = run_simulation(modelname, input_signals, params, varargin)
% Run model MODELNAME with parameters and inputs passed in as key/value pairs.
% If the same key/value pair is repeated, the first one wins.

  if any(strcmpi(varargin, 'debug'))
    debug = true;
  else
    debug = false;
  end

  % Augment with simulation base settings
  if exist(fullfile(rootpath, 'params', ['params_' modelname '.m']), 'file')
    base_params = feval(['params_' modelname]);
    params      = {params{:} base_params{:}};
  end

  if not(mod(numel(params), 2) == 0)
    error('Simulation parameters must come in pairs!');
  end

  if not(mod(numel(input_signals), 2) == 0)
    error('Simulation input signals must come in pairs!');
  end

  if not(any(strcmp(input_signals, 'time')))
    error('Simulation input signals must contain a time vector');
  end

  % Create structure for simulation inputs
  simin.time = input_signals{find(strcmp(input_signals, 'time'))+1};
  if debug
    assignin('base', 'simin', simin);
  end

  % Open test harness
  [testharnessname, inputnames] = create_testharness(modelname, simin.time);

  % Assign simulation inputs to simin struct
  for vidx = numel(input_signals):-2:1
    if debug
      assignin('base', 'tmpvar', input_signals{vidx});
      evalin('base', ['simin.' input_signals{vidx-1} ' = tmpvar;']);
      evalin('base', 'clear tmpvar');
    else
      simin.(input_signals{vidx-1}) = input_signals{vidx};
    end
  end

  % Stub non-assigned inputs
  stub_inputs = setdiff(inputnames, input_signals(1:2:end));
  for sidx = 1:numel(stub_inputs)
    if debug
      assignin('base', 'tmpvar', benign_signal_builder(stub_inputs{sidx}, max(evalin('base', 'simin.time'))));
      evalin('base', ['simin.' stub_inputs{sidx} ' = tmpvar;']);
      evalin('base', 'clear tmpvar');
    else
      simin.(stub_inputs{sidx}) = benign_signal_builder(stub_inputs{sidx}, max(simin.time));
    end
  end

  % Assign params to workspace
  for vidx = numel(params):-2:1
    paramname = params{vidx-1};
    if debug
      base_vars = evalin('base', 'whos');
      param_exists = any(strcmp({base_vars.name}, paramname));
      if param_exists && isa(evalin('base', paramname), 'BACE.Parameter') && not(isa(params{vidx}, 'BACE.Parameter'))
        assignin('base', 'tmpvar', params{vidx});
        evalin('base', [paramname '.Value = tmpvar;']);
        evalin('base', 'clear tmpvar');
      else
        assignin('base', paramname, params{vidx});
      end
    else
      if exist(paramname, 'var') && isa(eval(paramname), 'BACE.Parameter') && not(isa(params{vidx}, 'BACE.Parameter'))
        eval([paramname '.Value = params{vidx};']);
      else
        assign_var(paramname, params{vidx});
      end
    end
  end

  if debug
    source_workspace = 'base';
  else
    source_workspace = 'current';
  end

  % Debug model if required
  if debug, keyboard; end

  % Run test harness
  simout_raw = sim(testharnessname, ...
    'SrcWorkspace', source_workspace, ...
    'ReturnWorkspaceOutputs', 'on' ...
  );

  % Convert output to sensible struct
  outvars = get(simout_raw);
  simout = struct();
  for vidx = 1:numel(outvars)
    simout.(regexprep(outvars{vidx}, '_simout$', '')) = get(simout_raw, outvars{vidx});
  end

  % Add time vector
  simout.time = simin.time;

  % Close model
  % bdclose(testharnessname);

  % Clear simulation inputs from base workspace if debugging
  if debug
    for vidx = 1:2:numel(input_signals), evalin('base', ['clear ' input_signals{vidx}]); end
    for sidx = 1:2:numel(stub_inputs), evalin('base', ['clear ' stub_inputs{sidx}]); end
    for pidx = 1:2:numel(params), evalin('base', ['clear ' params{pidx}]); end
  end

end
