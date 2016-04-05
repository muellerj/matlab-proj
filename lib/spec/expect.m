function expect(condition)
%FUNCTION EXPECT
%
% Part of the unit test framework. Tests, whether a given condition is true and
% stores the outcome in GLOBAL ASSERTIONS.

  % Guard against stupid data types
  condition = logical(condition);

  if not(isscalar(condition))
    error('Condition must be a scalar boolean value!');
  end

  global ASSERTIONS; if isempty(ASSERTIONS), ASSERTIONS = {}; end
  [stack, ~] = dbstack;

  assertion = struct();
  assertion.stack = stack(2);
  assertion.outcome = condition;
  ASSERTIONS = {ASSERTIONS{:} assertion};

  if condition
    fprintf('.');
  else
    fprintf('F');
  end
end
