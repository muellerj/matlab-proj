function bpos = blockposition(block_handle)
  block_pos = get_param(block_handle, 'Position');
  bpos = [block_pos(1) block_pos(2)];
end
