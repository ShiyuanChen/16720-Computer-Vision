function [histInter] = distanceToSet(wordHist, histograms)

x=repmat(wordHist,1,size(histograms,2));
histInter=sum(min(x,histograms));
%histInter=sum(x.*histograms)./(((sum(x.^2)).^0.5).*((sum(histograms.^2)).^0.5));