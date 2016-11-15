function cond = stats_with(str, pat)

  cond = strcmp(str(1:min(length(pat), length(str))), pat);

end
