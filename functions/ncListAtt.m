function attlist = ncListAtt(file, variable)

info = ncinfo(file, variable);
attlist = {info.Attributes(:).Name};
