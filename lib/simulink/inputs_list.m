function list = inputs_list
%INPUTS_LIST
%
% Return a list of all input signals. All inputs must pass through
% the SignalTreatment wrapper

  list = {};

  blocks = find_system('signal_treatment', 'SearchDepth', 2, 'Type', 'block');
  for bidx = 1:numel(blocks)
    if strcmp(get_param(blocks{bidx}, 'BlockType'), 'Inport')
      list{end+1} = char(regexp(blocks{bidx}, '(\w+)$', 'tokens', 'once'));
    end

  list = unique(list);

end
