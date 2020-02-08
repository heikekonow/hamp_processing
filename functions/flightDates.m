% List of flight dates, flight numbers and corresponding campaign names
function [NARVALdates, NARVALdatenum] = flightDates

NARVALdates =  {'20131210','01','NARVAL-South', 1;...
                '20131211','02','NARVAL-South', 1;...
                '20131212','03','NARVAL-South', 1;...
                '20131214','04','NARVAL-South', 1;...
                '20131215','05','NARVAL-South', 1;...
                '20131216','06','NARVAL-South', 1;...
                '20131219','07','NARVAL-South', 1;...
                '20131220','08','NARVAL-South', 1;...
                '20140107','09','NARVAL-North', 2;...
                '20140109','10','NARVAL-North', 2;...
                '20140112','11','NARVAL-North', 2;...
                '20140118','12','NARVAL-North', 2;...
                '20140120','13','NARVAL-North', 2;...
                '20140121','14','NARVAL-North', 2;...
                '20140122','15','NARVAL-North', 2;
                '20160808','01','NARVAL-II', 3;
                '20160810','02','NARVAL-II', 3;
                '20160812','03','NARVAL-II', 3;
                '20160815','04','NARVAL-II', 3;
                '20160817','05','NARVAL-II', 3;
                '20160819','06','NARVAL-II', 3;
                '20160822','07','NARVAL-II', 3;
                '20160824','08','NARVAL-II', 3;
                '20160826','09','NARVAL-II', 3;
                '20160830','10','NARVAL-II', 3;
                '20160917','01','NAWDEX', 4;
                '20160921','02','NAWDEX', 4;
                '20160923','03','NAWDEX', 4;
                '20160926','04','NAWDEX', 4;
                '20160927','05','NAWDEX', 4;
                '20161001','06','NAWDEX', 4;
                '20161006','07','NAWDEX', 4;
                '20161009','08','NAWDEX', 4;
                '20161010','09','NAWDEX', 4;
                '20161013','10','NAWDEX', 4;
                '20161014','11','NAWDEX', 4;
                '20161015','12','NAWDEX', 4;
                '20161018','13','NAWDEX', 4;
                '20190516','01','PreEUREC4A', 6;
                '20190517','02','PreEUREC4A', 6;
                '20200119','01','EUREC4A', 5;
                '20200122','02','EUREC4A', 5;
                '20200124','03','EUREC4A', 5;
                '20200126','04','EUREC4A', 5;
                '20200128','05','EUREC4A', 5;
                '20200130','06','EUREC4A', 5;
                '20200131','07','EUREC4A', 5;
                '20200202','08','EUREC4A', 5;
                '20200205','09','EUREC4A', 5;
                '20200207','10','EUREC4A', 5;
                '20200209','11','EUREC4A', 5;
                '20200211','12','EUREC4A', 5;
                '20200213','13','EUREC4A', 5;
                '20200215','14','EUREC4A', 5;
                '20200218','15','EUREC4A', 5
                };

NARVALdatenum = datenum(NARVALdates(:,1),'yyyymmdd');