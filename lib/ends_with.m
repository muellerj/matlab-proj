function cond = ends_with(str, pat)

  cond = strcmp(str(end-min(length(pat), length(str))+1:end), pat);

end
