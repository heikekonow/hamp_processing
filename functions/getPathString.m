function path = getPathString(string)

ind_slash = regexp(string,'/');

path = string(1:ind_slash(end));