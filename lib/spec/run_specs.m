function run_specs(varargin)
%RUN_SPECS [SEARCHSTR]
%
%  Run all available specs matching [projectpath]/spec/**/*SEARCHSTR*_spec.m

  global ASSERTIONS;
  ASSERTIONS = {};
  EXCEPTIONS = {};

  if nargin > 0
    specfiles = rdir(fullfile(projectpath, 'spec', '**', ['*' varargin{1} '*_spec.m']));
  else
    specfiles = rdir(fullfile(projectpath, 'spec', '**', ['*_spec.m']));
  end

  disp(['Running ' pluralise(numel(specfiles), 'specfile', 'specfiles')]);

  for fidx = 1:numel(specfiles)
    try
      [~, fname, ~] = fileparts(specfiles(fidx).name);
      feval(fname);
    catch exception
      EXCEPTIONS = {EXCEPTIONS{:} exception};
      fprintf('E');
    end
  end

  fprintf('\n');

  if not(isempty(EXCEPTIONS))
    for eidx = 1:numel(EXCEPTIONS), rethrow(EXCEPTIONS{eidx}); end
  end

  passes = cellfun(@(x) x.outcome, ASSERTIONS);

  if all(passes)
    fprintf('PASSED\n\n')
  else
    fprintf([pluralise(numel(find(passes == 0)), 'FAIL', 'FAILS') '\n\n']);

    for aidx = 1:numel(ASSERTIONS)
      if ASSERTIONS{aidx}.outcome == 0
        fprintf('Failure in %s: line %d\n', ...
          ASSERTIONS{aidx}.stack.file, ASSERTIONS{aidx}.stack.line);
      end
    end
  end

end

function outstr = pluralise(n, singular, plural)
  if n == 1
    outstr = ['1 ' singular];
  else
    outstr = [num2str(n) ' ' plural];
  end
end
