function uniMeas = transferData(uniData,instrData,indHeight,indTime)

    uniMeas = uniData;

    l = sub2ind(size(instrData),repmat(indHeight,1,length(indTime)),repmat(indTime,length(indHeight),1));

    uniMeas(~isnan(l)) = instrData(l(~isnan(l)));

end