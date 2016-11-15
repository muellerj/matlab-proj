function blockname = find_root_block(model)
  load_system(model);
  blockname = last(find_system(model, 'SearchDepth', 1));
end
