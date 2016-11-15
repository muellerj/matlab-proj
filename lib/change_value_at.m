function B = change_value_at(A, varargin)

  B = A;

  if all(size(A) > 1)
    if not(numel(varargin) == 3)
      error('Wrong number of arguments');
    end
    B(varargin{1}, varargin{2}) = varargin{3};
  else
    if not(numel(varargin) == 2)
      error('Wrong number of arguments');
    end
    B(varargin{1}) = varargin{2};
  end

end
