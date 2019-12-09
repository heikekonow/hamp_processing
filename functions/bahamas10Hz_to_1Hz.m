function ind1Hz = bahamas10Hz_to_1Hz(bahamasTime)

bahamasTimeVec = datevec(bahamasTime);

bahamasTimeSeconds = bahamasTimeVec(:,end);

ind1Hz = floor(bahamasTimeSeconds)==bahamasTimeSeconds;