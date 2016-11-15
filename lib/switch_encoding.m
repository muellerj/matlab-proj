function switch_encoding(varargin)
%SWITCH_ENCODING

bdclose('all');

if nargin < 1
  slCharacterEncoding('UTF-8')
else
  if strcmp(lower(varargin{1}), 'bace')
    target_encoding = 'windows-1252';
  else
    target_encoding = varargin{1};
  end
  slCharacterEncoding(target_encoding);
end

