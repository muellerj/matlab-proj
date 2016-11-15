function sig_out = benign_signal_builder(name, varargin)

  if nargin < 2
    Tmax = 2;
  else
    Tmax = varargin{1};
  end

  % Determine data type
  if starts_with(name, 'QU_') || ...
     starts_with(name, 'ST_') || ...
     starts_with(name, 'OPMO_') || ...
     strcmp(name, 'CLT_0_ST') || ...
     strcmp(name, 'St_asd_deact')
    data_type = 'uint16';
  elseif strcmp(name, 'St_asd_mode')
    data_type = 'uint8';
  elseif starts_with(name, 'B_')
    data_type = 'boolean';
  else
    data_type = 'single';
  end

  sig_out = signal_builder('const', 'Value', value, 'DataType', data_type, 'Tmax', Tmax);

end
