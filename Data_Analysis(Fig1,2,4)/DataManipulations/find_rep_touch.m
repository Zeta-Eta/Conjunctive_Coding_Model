function [sametouchlabel,sametouch]=find_rep_touch(response,setsize)

% find 2 repetitive touches, and make a record

sametouch = [];
count = 1;
for i =1:setsize-1
    for j =i+1:setsize
        sametouchlabel{count,1}= [num2str(i),'-',num2str(j)]; 
        count = count+1;
       sametouch=[sametouch,sum(response(:,j)==response(:,i),1)];  
    end
end

