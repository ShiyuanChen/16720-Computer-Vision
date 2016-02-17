function [h] = getImageFeaturesSPM(layerNum, wordMap, dictionarySize)

layerNum=uint32(layerNum);
L=layerNum-1;
h=zeros(dictionarySize*(4^layerNum-1)/3,1);
his=cell(layerNum,1);
xstep=size(wordMap,1)/(2^L);
ystep=size(wordMap,2)/(2^L);
xptr=1;
yptr=1;
hptr=1; 
for j=1:2^L
    xptr=1;
    for i=1:2^L
        his{layerNum}(i,j,:)=getImageFeatures(wordMap(xptr:min(xptr+xstep-1,size(wordMap,1)),yptr:min(yptr+ystep-1,size(wordMap,2))),dictionarySize)/(4^double(L));
        h(dictionarySize*(hptr-1)+1:dictionarySize*hptr)=his{layerNum}(i,j,:)*(2^(-1));
        hptr=hptr+1;
        xptr=xptr+xstep;      
    end
    yptr=yptr+ystep;
end

for l=L:-1:1
    for n=1:2^(l-1)
        for m=1:2^(l-1)
            his{l}(m,n,:)=sum(sum(his{l+1}(2*m-1:2*m,2*n-1:2*n,:),1),2);
            if l>2
                h(dictionarySize*(hptr-1)+1:dictionarySize*hptr)=his{l}(m,n,:)*(2^(l-layerNum-1));
            else
                h(dictionarySize*(hptr-1)+1:dictionarySize*hptr)=his{l}(m,n,:)*(2^(-double(L)));
            end
            hptr=hptr+1;
        end
    end
end