function [interpolated_data,varargout] = interpolateData(time,data,allowedGaplength)
    
    % If data is not a vector
    if sum(size(data)==1)==0
        % If time axis is along first dimension: transpose
        if find(size(data)~=length(time))==2
            data = data';
        end
        % Loop along non time dimension
        for i=1:size(data,1)
            gaplength = countDataGapLength(data(i,:));
            dataInterp = interp1(time(~isnan(data(i,:))),...
                                data(i,~isnan(data(i,:))),...
                                time(~isnan(time)),'linear');
            dataInterp(gaplength>allowedGaplength) = nan;

            interpolated_data(i,:) = dataInterp;
            
            % Add flag for interpolated values
            interpolate_flag(i,:) = zeros(size(gaplength));
            interpolate_flag(i,gaplength>0&gaplength<=allowedGaplength) = 1;
            clear gaplength dataInterp
        end
    else
        gaplength = countDataGapLength(data);

        dataInterp = interp1(time(~isnan(data)),data(~isnan(data)),...
                            time,'linear');
        dataInterp(gaplength>allowedGaplength) = nan;

        interpolated_data = dataInterp;
        
        % Add flag for interpolated values
        interpolate_flag = zeros(size(gaplength));
        interpolate_flag(gaplength>0&gaplength<=allowedGaplength) = 1;
    end
    
    if nargout==2
        varargout{1} = interpolate_flag;
    end
    
end