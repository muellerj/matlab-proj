function assign_var(varname, value)
% ASSIGN_VAR
%
%  assign_var(varname, value)
%
%  Assign `value` to the variable named `varname` in the caller
%  workspace. Example:
%
%    varname = ['some_' num2str(10) '_compound'];
%    assign_var(varname, 100);
%    some_10_compound % => 100

assignin('caller', varname, value);