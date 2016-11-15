function element = last(ary)
  if iscell(ary)
    element = ary{end};
  else
    element = ary(end);
  end
end
