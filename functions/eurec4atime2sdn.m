function tNew = eurec4atime2sdn(tOld)

tNew = datenum(...
        datetime(tOld, 'ConvertFrom', 'epochtime','Epoch','2020-01-01'));