function out = is_bool(x)
  out = islogical(x) || (isnumeric(x) && all(x(:) == 0 | x(:) == 1));
end
