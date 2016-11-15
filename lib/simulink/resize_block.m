function resize_block(block_handle, newsize)
  block_position = blockposition(block_handle);
  set_param(block_handle, 'Position', [block_position block_position] + [0 0 newsize]);
end
