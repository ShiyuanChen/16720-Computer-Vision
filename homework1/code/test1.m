function [fresponses] = test1(filterResponses,I)
fresponses=zeros(size(I,1),size(I,2),3);
for j=1:size(I,2)
    for i=1:size(I,1)
        for k= 1:3
            fresponses(i,j,k)=uint8(filterResponses(size(I,1)*(j-1)+i,30+k));
        end
    end
end
fresponses=uint8(fresponses);