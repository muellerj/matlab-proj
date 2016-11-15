function inv_hsh = swap_hash(hsh)

  if not(mod(numel(hsh), 2) == 0)
    error('Input hash must have an even number of elements');
  end

  inv_hsh = hsh;

  for hidx = 1:2:numel(inv_hsh)
    tmp             = inv_hsh{hidx};
    inv_hsh{hidx}   = inv_hsh{hidx+1};
    inv_hsh{hidx+1} = tmp;
  end

end
