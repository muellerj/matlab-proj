function bsize = blocksize(block_handle)
  block_pos = get_param(block_handle, 'Position');
  bsize = [block_pos(3) - block_pos(1), block_pos(4) - block_pos(2)];
end
