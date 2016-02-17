function [compareX, compareY] = makeTestPattern(patchWidth, nbits)
sigma2=patchWidth^2/25;
R = mvnrnd([ceil(patchWidth/2),ceil(patchWidth/2)],[sigma2,0;0,sigma2],nbits*2);
compareX=round(R(1:nbits,:));
compareY=round(R(nbits+1:2*nbits,:));
compareX(compareX>patchWidth)=patchWidth;
compareX(compareX<1)=1;
compareY(compareY>patchWidth)=patchWidth;
compareY(compareY<1)=1;
compareX=sub2ind([patchWidth,patchWidth], compareX(:,2), compareX(:,1));
compareY=sub2ind([patchWidth,patchWidth], compareY(:,2), compareY(:,1));
%compareX=randi(patchWidth^2,nbits,1);
%compareY=randi(patchWidth^2,nbits,1);
save('testPattern.mat','compareX','compareY');
