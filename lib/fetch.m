function value = fetch(hash, key)
%FUNCTION FETCH
%
% Provide a mechanism for fetching keys from matlab pseudo-hashes, e.g.
%
%   fetch({'foo', 1, 'bar', 2}, 'bar') => 2

  if not(mod(numel(hash), 2) == 0)
    error('Input hash must have an even number of elements');
  end

  idx = find(strcmp(hash, key));

  if isempty(idx)
    error(['Hash key ' key ' not found']);
  elseif numel(idx) > 1
    error(['Hash key ' key ' is not unique']);
  else
    value = hash{idx+1};

    % Extract value if key is a BACE Parameter
    if isa(value, 'BACE.Parameter')
      value = value.Value;
    end
  end

end
