function s = inport_struct(time, signal)
  s = struct();
  s.time = time;
  s.signals.values = signal;
end
