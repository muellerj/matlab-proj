function list = label_list(varargin)
%LABEL_LIST
%
% Return a list of all labels contained in the models under ./mdl

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
  modelfiles(strcmp(modelfiles, 'compound_lib.mdl')) = [];

  list = {};

  for midx = 1:numel(modelfiles)
    load_system(modelfiles{midx});
    appl_params = find_system(modelfiles{midx}, 'Tag', 'ApplicationParameter');

    for pidx = 1:numel(appl_params)
      if any(strcmp(fieldnames(get_param(appl_params{pidx}, 'ObjectParameters')), 'NumberOfTableDimensions'))
        n = str2num(get_param(appl_params{pidx}, 'NumberOfTableDimensions'));
        if n >= 0, list{end+1} = get_param(appl_params{pidx}, 'Table'); end
        if n >= 1, list{end+1} = get_param(appl_params{pidx}, 'BreakpointsForDimension1'); end
        if n >= 2, list{end+1} = get_param(appl_params{pidx}, 'BreakpointsForDimension2'); end
      else
        list{end+1} = get_param(appl_params{pidx}, 'Value');
      end
    end
  end

  list = unique(list);

end
