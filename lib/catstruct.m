function outstruct = catstruct(s1, s2)

  if not(isstruct(s1)) || not(isstruct(s2))
    error('Both arguments must be structs');
  end

  % By default, the first argument is passed through
  outstruct = s1;

  % Go through all fields of the 2nd struct and decide, what to do
  fnames = fieldnames(s2);

  if numel(outstruct) < 1
    outstruct = s2;
  else
    for sidx = 1:numel(s2)
      for fidx = 1:numel(fnames)
        outstruct(numel(s1)+sidx).(fnames{fidx}) = s2(sidx).(fnames{fidx});
      end
    end
  end

end
