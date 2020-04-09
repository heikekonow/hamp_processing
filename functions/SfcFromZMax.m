function zMax = SfcFromZMax(Z,z)

%% Calculate Maxima
zMax = nan(size(Z,2),1);
maxIndex = false(size(Z));
for i=1:size(Z,2)
    if ~isnan(max(Z(:,i),[],1))
        if max(Z(:,i))==0
            zMax(i) = NaN;
        else
%             maxIndex(:,i) = Z(:,i)==max(Z(:,i),[],1);
%             zMax(i) = z(maxIndex(:,i));
            zMax(i) = z(find(Z(:,i)==max(Z(:,i),[],1), 1, 'last'));
        end
    else
        maxIndex(:,i) = Z(:,i)==max(Z(:,i),[],1);
        zMax(i) = NaN;
    end
end
