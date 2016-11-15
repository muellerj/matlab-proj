function list = model_list

  list = dir(fullfile(rootpath, 'mdl', '*.mdl'));
  list = {list.name};

  for lidx = 1:numel(list)
    list{lidx} = regexprep(list{lidx}, '\.mdl$', '');
  end

  list(strcmp(list, 'compound')) = [];

end
