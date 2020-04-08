function assess_radiometer_data

% clear; 
close all

figures = 1;
calc = 0;
man_vals = 1;

campaign = 'NARVAL-I';
dates = get_campaignDates(campaign);

if figures
    for i=1:length(dates)

        path{1} = [getPathPrefix getCampaignFolder(dates{i}) 'radiometer/183/' dates{i}(3:end) '.BRT.NC'];
        path{2} = [getPathPrefix getCampaignFolder(dates{i}) 'radiometer/11990/' dates{i}(3:end) '.BRT.NC'];
        path{3} = [getPathPrefix getCampaignFolder(dates{i}) 'radiometer/KV/' dates{i}(3:end) '.BRT.NC'];

        tb = cell(3,1);
        for j=1:3
            tb{j} = ncread(path{j},'TBs');
            t{j} = ncread(path{j}, 'time');

            figure
            set(gcf,'Position',[1992 550 1620 376])
            plot(tb{j}','LineWidth',2)
            tick2text(gca,'xformat','%.0f')

            if j==1
                title([dates{i} ' - 183'])
            elseif j==2
                title([dates{i} ' - 11990'])
            elseif j==3
                title([dates{i} ' - KV']) 
            end
        end

%         pause

        clear tb t path
        close all
    end
end

%% Convert indices to times
if calc
%     radiometerErrorsLookup
    radiometerErrorsLookupInt

    errorcode = cell(10,3);
    pathBahamas = cell(1,3);
    bahamasFile = cell(1,3);
    tBah = cell(1,3);

    figure
    set(gcf,'Position',[-1806 41 1731 1068])

    k = 1;

    for i=1:length(dates)
        
        disp([num2str(i) ' - ' dates{i}])

        path{1} = [getPathPrefix 'NANA_campaignData/radiometer/183/' dates{i}(3:end) '*.NC'];
        path{2} = [getPathPrefix 'NANA_campaignData/radiometer/11990/' dates{i}(3:end) '*.NC'];
        path{3} = [getPathPrefix 'NANA_campaignData/radiometer/KV/' dates{i}(3:end) '*.NC'];

        pathBahamas{i} = [getPathPrefix 'NANA_campaignData/bahamas/'];
        bahamasFile{i} = cell2mat(listFiles([pathBahamas{i} '*' dates{i} '*.nc']));
        tBah{i} = unixtime2sdn(ncread([pathBahamas{i} bahamasFile{i}],'TIME'));

        t = cell(3,1);
        tUse = cell(3,1);
        for j=1:3
            filepath = listFiles(path{j},'full');
            time = cell(1,length(filepath));
            for m=1:length(filepath)
                 time{m} = time2001_2sdn(double(ncread(filepath{m},'time')));
            end
            time = time';
            t{j} = transpose(cell2mat(time));
            
            clear time
            
            ind = indRadiometerTimeJumps(t{j});
            t{j}(ind) = nan;
            tUse{j} = t{j};
%             tUse{j} = linspace(t{j}(1),t{j}(end),numel(t{j}));

            % Get index of dates in error cell
            l = find(strcmp(errors{1,j}(:,1),dates{i}));
            
            % give length of radiometer time
            errorcode{i,j} = zeros(size(t{j}));
            
            if ~cellfun(@isempty,errors{1,j}{l,2})
                index = indexFromError(errors{1,j}{l,2});
                % if error, set to 1
                errorcode{i,j}(index) = 1;
            end
            
            if j==1
                l = find(strcmp(sawtooth{1,j}(:,1),dates{i}));
                if ~cellfun(@isempty,sawtooth{1,j}{l,2})
                    index = indexFromError(sawtooth{1,j}{l,2});
                    
                    % if saw tooth set to 2
                    errorcode{i,j}(index) = 2;
                end
            end
            
            % if before take-off or after landing, set to 3
            errorcode{i,j}(1:find(tUse{j}<tBah{i}(1),1,'last')) = 3;
            errorcode{i,j}(find(tUse{j}>tBah{i}(end),1,'first'):end) = 3;

            e{i,j} = errorcode{i,j};
            tPlot{i,j} = t{j};
            tPlot{i,j}(e{i,j}==3) = [];
            e{i,j}(e{i,j}==3) = [];
%             tPlot{i,j} = linspace(tBah{i}(1),tBah{i}(end),numel(e{i,j}));

        end
        
        if strcmp(campaign,'NAWDEX')
            subplot(3,5,k)
        elseif strcmp(campaign,'NARVAL-II')
            subplot(3,4,k)
        end
    %     plot(t{1},errorcode{i,1},t{2},errorcode{i,2},t{3},errorcode{i,3},...
    %             'LineWidth',2)

%         if ~sum(e{i,1})==0
%             fill([tPlot{i,1} fliplr(tPlot{i,1})],[zeros(1,length(tPlot{i,1}));fliplr(e{i,1}')]',...
%                 'b','FaceColor',[195, 212, 232]./255,'EdgeColor',[79, 129, 189]./255,...
%                 'LineWidth',2)
%         end
%         hold on  
% 
%         if ~sum(e{i,2})==0
%             fill([tPlot{i,2} fliplr(tPlot{i,2})],[zeros(1,length(tPlot{i,2}));fliplr(e{i,2}')]',...
%                     'r','FaceColor',[234, 168, 168]./255,'EdgeColor',[192, 0, 0]./255,...
%                     'LineWidth',2)
%         end
%         if ~sum(e{i,3})==0 
%             fill([tPlot{i,3} fliplr(tPlot{i,3})],[zeros(1,length(tPlot{i,3}));fliplr(e{i,3}')]',...
%                     'y','FaceColor',[255, 238, 168]./255,'EdgeColor',[255, 204, 0]./255,...
%                     'LineWidth',2)
%         end
        

        plot(tPlot{i,1},e{i,1},tPlot{i,2},e{i,2},tPlot{i,3},e{i,3},...
                'LineWidth',2)
        if k==length(dates)
            legend({'183','11990','KV'},'Location',[0.46 0.25 0.05 0.07])
        end

        finetunefigures
        set(gca,'YLim',[-0.5 2.5],'YTick',[0 1 2])
        xlabel('Time (UTC)')
        title(dates{i})
        setFontSize(gcf,14)
        datetick('x','HH')

        clear tBah t

        k = k+1;
    end

    th = annotation('textbox',[0.6,0.1,0.1,0.1],...
            'String',{'0: ok';'1: error';'2: saw tooth'},'Fontsize',14,...
            'EdgeColor','none');

    export_fig([getPathPrefix 'NANA_campaignData/figures/radiometerErrorsAssessment' campaign],'-pdf')

    % Percentage of saw tooth pattern
    p2 = cell2mat(cellfun(@(x) round(sum(x==2)./numel(x).*100,3),e,'UniformOutput',false));
    % Percentage of errors
    p1 = cell2mat(cellfun(@(x) round(sum(x==1)./numel(x).*100,3),e,'UniformOutput',false));

    save([getPathPrefix 'NANA_campaignData/mat/radiometerErrorAssessment_' campaign])
else
    load([getPathPrefix 'NANA_campaignData/mat/radiometerErrorAssessment_' campaign])
end


if man_vals && strcmp(campaign,'NAWDEX')
    %% Manually calculated error percentages
    % columns 1: 183; 2:119/90; 3: KV
    p1 = zeros(13,3);
    p1(3,1) = 8.7;
    p1(4,:) = [0.3 0.5 0.3];
    p1(7,1) = 0.2;
    p1(9,1) = 27;
    p1(10,1) = 67;
    p1(12,1) = 20;
    p1(13,1) = 21;

    % Saw tooth only 183
    p2 = zeros(13,1);
    p2(9) = 6;
    p2(11) = 9;
end

%% Plot 183

datelabels = [repmat('RF',length(dates),1) num2str([1:length(dates)]','%02d') repmat(', ',length(dates),1) ...
                datestr(datenum(dates,'yyyymmdd'),'dd.mm.')];

figure
set(gcf,'Position',[-772 296 656 721])
bh = barh(1:length(dates),[p1(:,1) p2(:,1) 100-p2(:,1)-p1(:,1)],'stacked');

set(bh(3),'FaceColor',[79, 129, 189]./255,'EdgeColor',[1 1 1]) % ok
set(bh(1),'FaceColor',[183, 187, 194]./255,'EdgeColor',[1 1 1]) % error
set(bh(2),'FaceColor',[53, 151, 143]./255,'EdgeColor',[1 1 1]) % sawtooth
set(gca,'YTickLabel',datelabels)
finetunefigures
setFontSize(gcf,14)
grid off
set(gca,'TickLength',[ 0 0 ])
set(gca,'YDir','reverse')
set(gca,'YLim',[0.5 length(dates)+0.5])
xlabel('(%)')
% set(gca,'XLim',[-2 100])


ax1 = gca;
ax2 = axes('Position', get(ax1, 'Position'),'Color','none');
set(ax2,'XTick',[],'YTick',[],'XColor','w','YColor','w','box','on','layer','top')

if strcmp(campaign,'NAWDEX')
    lh = legend(bh,'no data','saw tooth','data');
else
    lh = legend(bh,'errors','saw tooth','data');
end
set(lh,'Position',get(lh,'Position')+[0 0.07 0 0],...
       'EdgeColor','none','FontSize',14)
export_fig([getPathPrefix 'NANA_campaignData/figures/radiometer183ErrorAssessment_' campaign],'-pdf')
export_fig([getPathPrefix 'NANA_campaignData/figures/radiometer183ErrorAssessment_' campaign],'-png','-r600')

%% Plot 119/90

% datelabels = [repmat('RF',10,1) num2str([1:10]','%02d') repmat(', ',10,1) ...
%                 datestr(datenum(dates,'yyyymmdd'),'dd.mm.')];

figure
set(gcf,'Position',[-1438 296 656 721])
bh = barh(1:length(dates),[p1(:,2) 100-p1(:,2)],'stacked');

set(bh(2),'FaceColor',[79, 129, 189]./255,'EdgeColor',[1 1 1])
set(bh(1),'FaceColor',[183, 187, 194]./255,'EdgeColor',[1 1 1])
% set(bh(3),'FaceColor',[53, 151, 143]./255,'EdgeColor',[1 1 1])
set(gca,'YTickLabel',datelabels)
finetunefigures
setFontSize(gcf,14)
grid off
set(gca,'TickLength',[ 0 0 ])
set(gca,'YDir','reverse')
set(gca,'YLim',[0.5 length(dates)+0.5])
xlabel('(%)')
% set(gca,'XLim',[-2 100])


ax1 = gca;
ax2 = axes('Position', get(ax1, 'Position'),'Color','none');
set(ax2,'XTick',[],'YTick',[],'XColor','w','YColor','w','box','on','layer','top')


if strcmp(campaign,'NAWDEX')
    lh = legend(bh,'no data','data');
else
    lh = legend(bh,'errors','data');
end
set(lh,'Position',get(lh,'Position')+[0 0.05 0 0],...
       'EdgeColor','none','FontSize',14)
export_fig([getPathPrefix 'NANA_campaignData/figures/radiometer11990ErrorAssessment_' campaign],'-pdf')
export_fig([getPathPrefix 'NANA_campaignData/figures/radiometer11990ErrorAssessment_' campaign],'-png','-r600')

%% KV
% 
% datelabels = [repmat('RF',10,1) num2str([1:10]','%02d') repmat(', ',10,1) ...
%                 datestr(datenum(dates,'yyyymmdd'),'dd.mm.')];

figure
set(gcf,'Position',[-1889 295 656 721])
bh = barh(1:length(dates),[p1(:,3) 100-p1(:,3)],'stacked');

set(bh(2),'FaceColor',[79, 129, 189]./255,'EdgeColor',[1 1 1])
set(bh(1),'FaceColor',[183, 187, 194]./255,'EdgeColor',[1 1 1])
% set(bh(3),'FaceColor',[53, 151, 143]./255,'EdgeColor',[1 1 1])
set(gca,'YTickLabel',datelabels)
finetunefigures
setFontSize(gcf,14)
grid off
set(gca,'TickLength',[ 0 0 ])
set(gca,'YDir','reverse')
set(gca,'YLim',[0.5 length(dates)+0.5])
xlabel('(%)')
% set(gca,'XLim',[-2 100])


ax1 = gca;
ax2 = axes('Position', get(ax1, 'Position'),'Color','none');
set(ax2,'XTick',[],'YTick',[],'XColor','w','YColor','w','box','on','layer','top')

if strcmp(campaign,'NAWDEX')
    lh = legend(bh,'no data','data');
else
    lh = legend(bh,'errors','data');
end
set(lh,'Position',get(lh,'Position')+[0 0.05 0 0],...
       'EdgeColor','none','FontSize',14)
export_fig([getPathPrefix 'NANA_campaignData/figures/radiometerKVErrorAssessment_' campaign],'-pdf')
export_fig([getPathPrefix 'NANA_campaignData/figures/radiometerKVErrorAssessment_' campaign],'-png','-r600')

%% All in one

% 183
% datelabels = [repmat('RF',10,1) num2str([1:10]','%02d') repmat(', ',10,1) ...
%                 datestr(datenum(dates,'yyyymmdd'),'dd.mm.')];

figure
set(gcf,'Position',[23 337 1893 733])

subtightplot(1,3,1,[0.01,0.02],0.1,0.08)
bh = barh(1:length(dates),[p2(:,1) p1(:,1) 100-p2(:,1)-p1(:,1)],'stacked');

set(bh(3),'FaceColor',[79, 129, 189]./255,'EdgeColor',[1 1 1])
set(bh(2),'FaceColor',[183, 187, 194]./255,'EdgeColor',[1 1 1])
set(bh(1),'FaceColor',[53, 151, 143]./255,'EdgeColor',[1 1 1])
set(gca,'YTickLabel',datelabels)
finetunefigures
setFontSize(gcf,14)
grid off
set(gca,'TickLength',[ 0 0 ])
set(gca,'YDir','reverse')
set(gca,'YLim',[0.5 length(dates)+0.5])
xlabel('(%)')
% set(gca,'XLim',[-2 100])
th = title('183');
set(th,'Position',get(th,'Position')+[-20 0 0])


ax1 = gca;
ax2 = axes('Position', get(ax1, 'Position'),'Color','none');
set(ax2,'XTick',[],'YTick',[],'XColor','w','YColor','w','box','on','layer','top')

if strcmp(campaign,'NAWDEX')
    lh = legend(bh,'no data','saw tooth','data');
else
    lh = legend(bh,'errors','saw tooth','data');
end
set(lh,'Position',get(lh,'Position')+[0 0.07 0 0],...
       'EdgeColor','none','FontSize',14)

   %%
% Plot 119/90

subtightplot(1,3,2,[0.01,0.02],0.1,0.08)
bh = barh(1:length(dates),[p1(:,2) 100-p1(:,2)],'stacked');

set(bh(2),'FaceColor',[79, 129, 189]./255,'EdgeColor',[1 1 1])
set(bh(1),'FaceColor',[183, 187, 194]./255,'EdgeColor',[1 1 1])
% set(bh(3),'FaceColor',[53, 151, 143]./255,'EdgeColor',[1 1 1])
set(gca,'YTickLabel',[])
finetunefigures
setFontSize(gcf,14)
grid off
set(gca,'TickLength',[ 0 0 ])
set(gca,'YDir','reverse')
set(gca,'YLim',[0.5 length(dates)+0.5])
xlabel('(%)')
% set(gca,'XLim',[-2 100])
th = title('119/90');
set(th,'Position',get(th,'Position')+[-20 0 0])


ax1 = gca;
ax2 = axes('Position', get(ax1, 'Position'),'Color','none');
set(ax2,'XTick',[],'YTick',[],'XColor','w','YColor','w','box','on','layer','top')

if strcmp(campaign,'NAWDEX')
    lh = legend(bh,'no data','data');
else
    lh = legend(bh,'errors','data');
end
set(lh,'Position',get(lh,'Position')+[0 0.05 0 0],...
       'EdgeColor','none','FontSize',14)

   %%
% KV

subtightplot(1,3,3,[0.01,0.02],0.1,0.08)
bh = barh(1:length(dates),[p1(:,3) 100-p1(:,3)],'stacked');

set(bh(2),'FaceColor',[79, 129, 189]./255,'EdgeColor',[1 1 1])
set(bh(1),'FaceColor',[183, 187, 194]./255,'EdgeColor',[1 1 1])
% set(bh(3),'FaceColor',[53, 151, 143]./255,'EdgeColor',[1 1 1])
set(gca,'YTickLabel',[])
finetunefigures
setFontSize(gcf,14)
grid off
set(gca,'TickLength',[ 0 0 ])
set(gca,'YDir','reverse')
set(gca,'YLim',[0.5 length(dates)+0.5])
xlabel('(%)')
% set(gca,'XLim',[-2 100])
th = title('KV');
set(th,'Position',get(th,'Position')+[-20 0 0])


ax1 = gca;
ax2 = axes('Position', get(ax1, 'Position'),'Color','none');
set(ax2,'XTick',[],'YTick',[],'XColor','w','YColor','w','box','on','layer','top')

if strcmp(campaign,'NAWDEX')
    lh = legend(bh,'no data','data');
else
    lh = legend(bh,'errors','data');
end
set(lh,'Position',get(lh,'Position')+[0 0.05 0 0],...
       'EdgeColor','none','FontSize',14)
   
   
export_fig([getPathPrefix 'NANA_campaignData/figures/radiometerAllErrorAssessment_' campaign],'-pdf')
export_fig([getPathPrefix 'NANA_campaignData/figures/radiometerAllErrorAssessment_' campaign],'-png','-r600')

end

function index = indexFromError(errorCell)

index = cell(1,length(errorCell));
for k=1:length(errorCell)
    index{k} = errorCell{k}(1):errorCell{k}(end);
end
index = cell2mat(index);

end
