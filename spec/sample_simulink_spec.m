function sample_simulink_spec

  % The sample model should pass through the input multiplied by K_FOO_BAR
  simout = run_simulation('sample_model', {
      'time', signal_builder('time'), ...
      'Md_in', signal_builder('const', 'Value', 10), ...
    }, {
      'K_FOO_BAR', 3 ...
    } ...
  );

  expect(all(simout.Md_out == 30));

end
