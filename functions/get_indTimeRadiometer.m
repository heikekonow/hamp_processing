function [indTimeUni,indTimeInstr] = get_indTimeRadiometer(uniTime,instrTime)

    oneSecond = 1/24/60/60;
    
    a = find(uniTime<=instrTime(1),1,'last');
    b = find(uniTime>=instrTime(end),1,'first');
    % length of relevant time interval
    t = b-a+1;
    
    indTimeUni = nan(t,1);
    indTimeInstr = nan(t,1);
%     duplicate_flag = 0;
%     indTime = nan(1,length(uniTime));
    k = 1;
    for i=a:b
        absDifference = abs(instrTime-uniTime(i));
        
        indMinim(k) = find(absDifference==min(absDifference),1,'first');
        
%          disp(['i = ' num2str(i) ' || indMinim = ' num2str(indMinim(i))])% ' || indTime = ' num2str(indTime(i))])% ' || instrTime = ' num2str(instrTime(indMinim(1))) ' uniTime = ' num2str(uniTime(i))])

        if k>1 && ((indMinim(k)~=indMinim(k-1)) || indMinim(k)~=indTimeInstr(k-1)) && absDifference(indMinim(k))<oneSecond% && ~isnan(indTime(i-1)))
            indTimeInstr(k) = indMinim(k);
            indTimeUni(k) = i;
%             duplicate_flag = 0;
%         elseif i>1
%             duplicate_flag = 1;
        elseif k==1
            indTimeInstr(k) = indMinim(k);
            indTimeUni(k) = i;
        end
        k = k+1; 
    end
    
% %     % Get unique time index elements
% %     unique_indTime = unique(indTime);
% %     % Count occurrence of each unique index
% %     countOfElements = hist(indTime,unique_indTime);
% %     % Index to each duplicate entry
% %     indexToRepeatedValue = countOfElements>0;
% %     
% %     indTime(indexToRepeatedValue) = nan;
% %     % Identify duplicate elements
% %     repeatedValues = unique_indTime(indexToRepeatedValue);
% %     % Count occurrence of duplicate entries
% %     numberOfAppearancesOfRepeatedValues = countOfElements(indexToRepeatedValue);
end