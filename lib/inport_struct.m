function s = inport_struct(simin, signal)
  s = struct();
  s.time = simin.time;
  s.signals.values = simin.(signal);
end
