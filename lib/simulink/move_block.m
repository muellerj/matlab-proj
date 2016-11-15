function move_block(block_handle, target_pos)
  block_size = blocksize(block_handle);
  set_param(block_handle, 'Position', [target_pos(1) target_pos(2) target_pos(1) target_pos(2)] + [0 0 block_size(1) block_size(2)]);
end
