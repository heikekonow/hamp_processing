function uniMeas = transferDataBahamas(uniData,instrData,indHeight,indTime)
    
    uniMeas = uniData;
    
    for i=1:length(indTime)
        if ~isnan(indHeight(i))
            uniMeas(indHeight(i),indTime(i)) = instrData(indTime(i));
        end
    end
end