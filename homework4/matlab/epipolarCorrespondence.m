function [ x2, y2 ] = epipolarCorrespondence( im1, im2, F, x1, y1 )
% epipolarCorrespondence:
%       im1 - Image 1
%       im2 - Image 2
%       F - Fundamental Matrix between im1 and im2
%       x1 - x coord in image 1
%       y1 - y coord in image 1

% Q2.6 - Todo:
%           Implement a method to compute (x2,y2) given (x1,y1)
%           Use F to only scan along the epipolar line
%           Experiment with different window sizes or weighting schemes
%           Save F, pts1, and pts2 used to generate view to q2_6.mat
%
%           Explain your methods and optimization in your writeup
x1=round(x1);
y1=round(y1);
W=5;
H=5;
scale=0.5;
weight=fspecial('gaussian', 2*ceil(scale*2.5)+1, scale);
range=50;
[sy,sx]= size(im2);
v1=[x1;y1;1];
l=F*v1;
s = sqrt(l(1)^2+l(2)^2);
l = l/s;
squareDist=inf;
x2=1;
y2=1;
if l(1) ~= 0
    for yy2=max(1+floor(H/2),y1-range):min(sy-floor(H/2),y1+range)
        xx2= -round((l(2) * yy2 + l(3))/l(1));
        patch1=im1(y1-floor(H/2):y1+floor(H/2),x1-floor(W/2):x1+floor(W/2));
        patch2=im2(yy2-floor(H/2):yy2+floor(H/2),xx2-floor(W/2):xx2+floor(W/2));
        pDist=sum(sum(double((patch1-patch2).^2).*weight,2),1);
        if pDist<=squareDist
            if pDist==squareDist && (xx2-x1)^2+(yy2-y1)^2>(x2-x1)^2+(y2-y1)^2
                continue;
            end
            squareDist=pDist;
            x2=xx2;
            y2=yy2;
        end
    end
else
    for xx2=max(1+floor(W/2),x1-range):min(sx-floor(W/2),x1+range)
        yy2= -round((l(1) * xx2 + l(3))/l(2));
        patch1=im1(y1-floor(H/2):y1+floor(H/2),x1-floor(W/2):x1+floor(W/2));
        patch2=im2(yy2-floor(H/2):yy2+floor(H/2),xx2-floor(W/2):xx2+floor(W/2));
        pDist=sum(sum(double((patch1-patch2).^2).*weight,2),1);
        if pDist<=squareDist
            if pDist==squareDist && (xx2-x1)^2+(yy2-y1)^2>(x2-x1)^2+(y2-y1)^2
                continue;
            end
            squareDist=pDist;
            x2=xx2;
            y2=yy2;
        end
    end
end
end

