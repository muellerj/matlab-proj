function [testharnessname, inputnames] = create_testharness(modelname, time)

  FROM_WORKSPACE_BLOCK_SIZE      = [200 20];
  TO_WORKSPACE_BLOCK_SIZE        = [120 20];
  CONVERT_BLOCK_SIZE             = [80 20];
  FROM_WORKSPACE_BLOCK_OFFSET    = [340 10];
  CONVERT_BLOCK_OFFSET           = [100 10];
  TO_WORKSPACE_BLOCK_OFFSET      = [20 -10];
  TESTBLOCK_POSITION             = [400 75];
  FUNCTIONCALLGENERATOR_POSITION = [410 10 235 30];

  testharnessname = ['testharness_' modelname];

  % Check if an existing testharness Simulink model is already opened.
  open_models = find_system('SearchDepth', 0);
  if find(strcmp(open_models, testharnessname))

    root_block = strrep(find_root_block(modelname), modelname, testharnessname);
    [inports outports] = find_ports(root_block);
    inport_paths = find_system(modelname, 'SearchDepth', 2, 'BlockType', 'Inport');
    for pidx = 1:numel(inports)
      inputnames{pidx} = last(strsplit(inport_paths{pidx}, '/'));
    end

  else

    % Create testharness model
    new_system(testharnessname);
    open_system(testharnessname);
    load_system(modelname);

    % Copy source system
    root_block = add_block(find_root_block(modelname), strrep(find_root_block(modelname), modelname, testharnessname));
    move_block(root_block, TESTBLOCK_POSITION);

    [inports outports] = find_ports(root_block);

    inport_paths  = find_system(modelname, 'SearchDepth', 2, 'BlockType', 'Inport');
    outport_paths = find_system(modelname, 'SearchDepth', 2, 'BlockType', 'Outport');

    % Create corresponding from_workspace and convert blocks
    for pidx = 1:numel(inports)
      % Determine input name
      inputnames{pidx} = last(strsplit(inport_paths{pidx}, '/'));

      % Create block
      from_workspace(pidx) = add_block('testharness_blocks/FromWorkspace', [testharnessname '/Inport' num2str(pidx)]);
      set_param(from_workspace(pidx), 'VariableName', ['inport_struct(simin, ''' inputnames{pidx} ''')']);
      set_param(from_workspace(pidx), 'SampleTime', num2str(mean(diff(time))));
      set_param(from_workspace(pidx), 'Interpolate', 'on');
      set_param(from_workspace(pidx), 'OutputAfterFinalValue', 'Holding final value');

      % Resize and align from_workspace block
      resize_block(from_workspace(pidx), FROM_WORKSPACE_BLOCK_SIZE);
      move_block(from_workspace(pidx), get_param(inports(pidx),'Position') - FROM_WORKSPACE_BLOCK_OFFSET);

      converter(pidx) = add_block('testharness_blocks/DataTypeConversion', [testharnessname '/Converter' num2str(pidx)]);

      % Resize and align converter block
      resize_block(converter(pidx), CONVERT_BLOCK_SIZE);
      move_block(converter(pidx), get_param(inports(pidx),'Position') - CONVERT_BLOCK_OFFSET);

      % Create connections
      add_line(testharnessname, ['Inport' num2str(pidx) '/1'], ['Converter' num2str(pidx) '/1']);
      add_line(testharnessname, ['Converter' num2str(pidx) '/1'], [get_param(root_block, 'Name') '/' num2str(pidx)]);
    end

    % Create corresponding to_workspace blocks
    for pidx = 1:numel(outports)
      % Create block
      to_workspace(pidx) = add_block('testharness_blocks/ToWorkspace', [testharnessname '/Outport' num2str(pidx)]);
      set_param(to_workspace(pidx), 'VariableName', [last(strsplit(outport_paths{pidx}, '/')) '_simout']);
      set_param(to_workspace(pidx), 'MaxDataPoints', 'numel(simin.time)');

      % Resize and align block
      resize_block(to_workspace(pidx), TO_WORKSPACE_BLOCK_SIZE);
      move_block(to_workspace(pidx), get_param(outports(pidx),'Position') + TO_WORKSPACE_BLOCK_OFFSET);

      % Create connection
      add_line(testharnessname, [get_param(root_block, 'Name') '/' num2str(pidx)], ['Outport' num2str(pidx) '/1']);
    end

  end

  % Configure simulink solver
  set_param(testharnessname, ...
    'SolverType'                , 'Fixed-step'                , ...
    'Solver'                    , 'FixedStepDiscrete'         , ...
    'LimitDataPoints'           , 'off'                       , ...
    'ParameterPrecisionLossMsg' , 'none'                      , ...
    'StartTime'                 , num2str(min(time))          , ...
    'StopTime'                  , num2str(max(time))          , ...
    'FixedStep'                 , num2str(mean(diff(time))));

  % Deal with models with no inputs
  if not(exist('inputnames', 'var'))
    inputnames = {};
  end

  % Add time to input names
  inputnames{end+1} = 'time';

end
