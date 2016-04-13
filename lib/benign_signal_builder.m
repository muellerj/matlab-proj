function sig_out = benign_signal_builder(name, Tmax)
  if strcmp(name, 'St_asd_deact')
    data_type = 'uint16';
  elseif strcmp(name(1:2), 'B_')
    data_type = 'uint16';
  else
    data_type = 'double';
  end

  sig_out = signal_builder('const', 'Value', 0, 'DataType', data_type, 'Tmax', Tmax);

end
