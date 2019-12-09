function [indTimeUni,indHeightUni,indSonde] = get_indHeightTimeDropsonde(uniTime,uniHeight,sondeTime,sondeHeight,varargin)

% !! flipud time and height from dropsonde !!
% !! delete nan entries in sonde data !!

if ~isempty(varargin) && strcmp(varargin{1},'notime')
    
    indHeightUni = nan(length(uniHeight),1);
    indSonde = nan(length(uniHeight),1);
    % find time of sonde release
    absTimeDifference = abs(sondeTime(1)-uniTime);
    indTimeMinim = find(absTimeDifference==min(absTimeDifference),1,'first');
    
    indTimeUni = indTimeMinim;
    
    for i=1:length(uniHeight)
        absHeightDifference = abs(sondeHeight-uniHeight(i));
        indHeightMinim = find(absHeightDifference==min(absHeightDifference),1,'first');
        if absHeightDifference(indHeightMinim)<29
            indHeightUni(i) = i;
            indSonde(i) = indHeightMinim;
        end
    end
else

    % find beginning of dropsonde time series in unified time
    a = find(uniTime<sondeTime(1),1,'last');
    b = find(uniTime>sondeTime(end),1,'first');
    % length of relevant time interval
    t = b-a;

    indHeight = nan(t,1);
    indTime = nan(t,1);

    timeLast = nan;
    k = 1;
    for i=a+1:b
        absTimeDifference = abs(sondeTime-uniTime(i));
        indTimeMinim = find(absTimeDifference==min(absTimeDifference),1,'first');

        absHeightDifference = abs(sondeHeight(indTimeMinim)-uniHeight);
        indHeightMinim = find(absHeightDifference==min(absHeightDifference),1,'first');


        if ~isempty(indHeightMinim)
            indTimeUni(k) = i;
            indSonde(k) = indTimeMinim;
            indHeightUni(k) = indHeightMinim;
        end
        k = k+1;    
    end

end





















% % % indHeight = nan(length(sondeTime),1);
% % % indTime = nan(length(sondeHeight),1);


% % % heightLast = nan;
% % % timeLast = nan;
% % % 
% % % for i=1:length(sondeTime)
% % %     if ~isnan(sondeTime(i)) && ~isnan(sondeHeight(i))
% % %         
% % %         absTimeDifference = abs(sondeTime(i)-uniTime);
% % %         indTimeMinim = find(absTimeDifference==min(absTimeDifference),1,'first');
% % %         
% % %         
% % %         absHeightDifference = abs(sondeHeight(i)-uniHeight);
% % %         indHeightMinim = find(absHeightDifference==min(absHeightDifference),1,'first');
% % %         
% % %         
% % %         if indTimeMinim~=timeLast && indHeightMinim~=heightLast
% % %             indHeight(i) = indHeightMinim;
% % %             indTime(i) = indTimeMinim;
% % %         end
% % %         
% % %         heightLast = indHeightMinim;
% % %         timeLast = indTimeMinim;
% % %     end
% % % end