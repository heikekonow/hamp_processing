function timeMask = timeOffsetUseMask(date,tRadar)

% Mark intervals that should be used
tIndex =    {'20131210',8500:length(tRadar);
             '20131211',1000:length(tRadar);
             '20131212', 500:length(tRadar);
             '20131214',   1:length(tRadar);
             '20131215', 400:length(tRadar);
             '20131216', 500:24000;
             '20131219', 750:length(tRadar);
             '20131220',   1:24000;
             '20140107',[ 400:3700 12000:length(tRadar)];
             '20140109',[  1:10700 12000:length(tRadar)];
             '20140112',2700:length(tRadar);
             '20140118',   1:length(tRadar);
             '20140120',   1:length(tRadar);
             '20140121',   1:length(tRadar);
             '20140122', 900:5000;
             '20160808',[8610:14870,35804:length(tRadar)];
             '20160810',   1:length(tRadar);
             '20160812',   1:length(tRadar);
             '20160815',[1:1428,2578:20447,26117:length(tRadar)];
             '20160817',[158:11669,27623:length(tRadar)];
             '20160819',[183:23227,26993:length(tRadar)];
             '20160822', 175:length(tRadar);
             '20160917',10303:24853;
             '20160921',2094:20093;
             '20160923', 461:31229;
             '20160926',   1:29645;
             '20160927', 322:length(tRadar);
             '20161001', 832:8046;
             '20161006', 225:31547;
             '20161009', 838:30431;
             '20161010', 202:25722;
             '20161013',   1:26672;
             '20161014',[289:14105,14821:21828];
             '20161015',[1148:1815,4155:6832,17183:19590,22544:25333];
             '20161018',[242:5815,6655:8713,9095:9697,10517:length(tRadar)];
%              '20161018',[242:5815,6655:8713,9095:9697,10517:14347]; % use this after radar data is reprocessed.
            };

index = cellfun(@(x) strcmp(x,date),tIndex(:,1))==1;

if sum(index)==0
    timeMask = true(size(tRadar));
else
    timeMask = tIndex{index,2};
end