function val = value_at(A, varargin)

  if nargin < 3
    if all(size(A) > 1)
      val = A(varargin{1},:);
    else
      val = A(varargin{1});
    end
  else
    val = A(varargin{1}, varargin{2});
  end

end
