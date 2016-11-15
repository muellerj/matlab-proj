function list = signal_list(varargin)
%SIGNAL_LIST
%
% Return a list of all measurable signals contained in the models under ./mdl.
% Measurable in this context means, that the signal must resolve to a
% Simulink.Signal object.

if nargin < 1
  modelname = '*.mdl';
else
  if ends_with(varargin{1}, '.mdl')
    modelname = varargin{1};
  else
    modelname = [varargin{1} '.mdl'];
  end
end

  modelfiles = dir(fullfile(rootpath, 'mdl', modelname));
  modelfiles = strrep({ modelfiles.name }, '.mdl', '');
  modelfiles(strcmp(modelfiles, 'compound.mdl')) = [];

  list = {};

  for midx = 1:numel(modelfiles)
    load_system(modelfiles{midx});
    signals = find_system(modelfiles{midx}, 'FindAll', 'on', 'RegExp', 'on', 'Type', 'line', 'Name', '\w');

    for sidx = 1:numel(signals)
      if get(signals(sidx), 'MustResolveToSignalObject')
        list{end+1} = get(signals(sidx), 'Name');
      end
    end
  end

  list = unique(list);

end
