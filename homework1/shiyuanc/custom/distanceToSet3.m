function [histInter] = distanceToSet(wordHist, histograms)

x=repmat(wordHist,1,size(histograms,2));
histInter=sum((x-histograms).^2).^0.5;