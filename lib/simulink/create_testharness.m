function [testharnessname, inputnames] = create_testharness(modelname, time)

  WORKSPACE_EXCHANGE_BLOCK_SIZE = [120 20];
  FROM_WORKSPACE_BLOCK_OFFSET   = [140 10];
  TO_WORKSPACE_BLOCK_OFFSET     = [20 -10];
  TESTBLOCK_POSITION            = [200 50];

  testharnessname = ['testharness_' modelname];

  % Check if an existing testharness Simulink model is already opened.
  % If so, it shall be closed without saving before running the program.
  open_models = find_system('SearchDepth', 0);
  if find(strcmp(open_models, testharnessname))
      warning('Old model closed...');
      bdclose(testharnessname)
  end

  % Create testharness model
  new_system(testharnessname);
  open_system(testharnessname);
  load_system(modelname);

  % Copy source system
  root_block = add_block(find_root_block(modelname), strrep(find_root_block(modelname), modelname, testharnessname));
  move_block(root_block, TESTBLOCK_POSITION);

  % Find connectivity ports
  [inports outports]  = find_ports(root_block);

  inport_paths  = find_system(modelname, 'SearchDepth', 2, 'BlockType', 'Inport');
  outport_paths = find_system(modelname, 'SearchDepth', 2, 'BlockType', 'Outport');

  % Create corresponding from_workspace blocks
  for pidx = 1:numel(inports)
    % Determine input name
    inputnames{pidx} = last(strsplit(inport_paths{pidx}, '/'));

    % Create block
    from_workspace(pidx) = add_block('built-in/From Workspace', [testharnessname '/Inport' num2str(pidx)]);
    set_param(from_workspace(pidx), 'VariableName', ['inport_struct(time, ' inputnames{pidx} ')']);
    set_param(from_workspace(pidx), 'SampleTime', num2str(mean(diff(time))));

    % Resize and align block
    resize_block(from_workspace(pidx), WORKSPACE_EXCHANGE_BLOCK_SIZE);
    move_block(from_workspace(pidx), get_param(inports(pidx),'Position') - FROM_WORKSPACE_BLOCK_OFFSET);

    % Create connection
    add_line(testharnessname, ['Inport' num2str(pidx) '/1'], [get_param(root_block, 'Name') '/' num2str(pidx)]);
  end


  % Create corresponding to_workspace blocks
  for pidx = 1:numel(outports)
    % Create block
    to_workspace(pidx) = add_block('built-in/To Workspace', [testharnessname '/Outport' num2str(pidx)]);
    set_param(to_workspace(pidx), 'VariableName', last(strsplit(outport_paths{pidx}, '/')));
    set_param(to_workspace(pidx), 'MaxDataPoints', num2str(numel(time)));

    % Resize and align block
    resize_block(to_workspace(pidx), WORKSPACE_EXCHANGE_BLOCK_SIZE);
    move_block(to_workspace(pidx), get_param(outports(pidx),'Position') + TO_WORKSPACE_BLOCK_OFFSET);

    % Create connection
    add_line(testharnessname, [get_param(root_block, 'Name') '/' num2str(pidx)], ['Outport' num2str(pidx) '/1']);
  end

  % Configure simulink solver
  set_param(testharnessname, ...
    'SolverType', 'Fixed-step', ...
    'Solver', 'FixedStepDiscrete', ...
    'StartTime', num2str(min(time)), ...
    'StopTime', num2str(max(time)), ...
    'FixedStep', num2str(mean(diff(time))));

  % Deal with models with no inputs
  if not(exist('inputnames', 'var'))
    inputnames = {};
  end

  % Add time to input names
  inputnames{end+1} = 'time';

end
