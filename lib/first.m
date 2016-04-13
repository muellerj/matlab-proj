function element = first(ary)
  if iscell(ary)
    element = ary{1};
  else
    element = ary(1);
  end
end
