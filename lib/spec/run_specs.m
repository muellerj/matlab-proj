function run_specs(varargin)
%RUN_SPECS [SEARCHSTR]
%
%  Run all available specs matching
%    [rootpath]/spec/**/*SEARCHSTR*_spec.m or
%    [rootpath]/spec/*SEARCHSTR*/*_spec.m.

  global ASSERTIONS;
  ASSERTIONS = {};
  EXCEPTIONS = {};

  if nargin > 0
    specfiles = catstruct(...
      rdir(fullfile(rootpath, 'spec', '**', ['*' varargin{1} '*_spec.m'])), ...
      rdir(fullfile(rootpath, 'spec', ['*' varargin{1} '*'], '*_spec.m')));
  else
    specfiles = rdir(fullfile(rootpath, 'spec', '**', ['*_spec.m']));
  end

  specfiles = unique({specfiles.name});

  disp(['Running ' pluralise(numel(specfiles), 'specfile', 'specfiles')]);

  % Close all testharness models
  models = find_system('SearchDepth', 0);
  for midx = 1:numel(models)
    if starts_with(models{midx}, 'testharness_')
      bdclose(models{midx});
    end
  end
  warning('off','Simulink:blocks:AssumingDefaultSimStateForSFcn')

  for fidx = 1:numel(specfiles)
    try
      [~, fname, ~] = fileparts(specfiles{fidx});
      feval(fname);
    catch exception
      EXCEPTIONS = {EXCEPTIONS{:} exception};
      fprintf('E');
    end
  end

  fprintf('\n');

  if not(isempty(EXCEPTIONS))
    for eidx = 1:numel(EXCEPTIONS)
      disp(EXCEPTIONS{eidx}.message);
      for cidx = 1:numel(EXCEPTIONS{eidx}.cause)
        disp(EXCEPTIONS{eidx}.cause{cidx});
      end
      for sidx = 1:numel(EXCEPTIONS{eidx}.stack)
        fprintf('%s:%d\n' ,EXCEPTIONS{eidx}.stack(sidx).file, EXCEPTIONS{eidx}.stack(sidx).line);
      end
      disp(' ');
    end
  end

  passes = cellfun(@(x) x.outcome, ASSERTIONS);

  if not(isempty(EXCEPTIONS))
    fprintf([pluralise(numel(EXCEPTIONS), 'ERROR', 'ERRORS') '\n\n']);
  end

  if all(passes) && isempty(EXCEPTIONS)
    fprintf('PASSED\n\n')
  elseif numel(find(passes == 0) > 0)
    fprintf([pluralise(numel(find(passes == 0)), 'FAIL', 'FAILS') '\n\n']);

    for aidx = 1:numel(ASSERTIONS)
      if ASSERTIONS{aidx}.outcome == 0
        fprintf('Failure in %s: line %d\n', ...
          ASSERTIONS{aidx}.stack.file, ASSERTIONS{aidx}.stack.line);
      end
    end
  end

  % Close all testharness models
  models = find_system('SearchDepth', 0);
  for midx = 1:numel(models)
    if starts_with(models{midx}, 'testharness_')
      bdclose(models{midx});
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
