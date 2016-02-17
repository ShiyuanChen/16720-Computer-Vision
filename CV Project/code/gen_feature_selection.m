% Generate randomly sepecet rectoangles to produce features of local sum
nFeatures = 5000;
h = 128;
w = 64;

layer=randi(10,nFeatures,1);
count=1;
x1=randi(w,nFeatures,1);
y1=randi(h,nFeatures,1);
x2=zeros(nFeatures,1);
y2=zeros(nFeatures,1);

while count <=nFeatures
    x2(count)=randi(w);
    y2(count)=randi(h);
    if abs((x1(count)-x2(count))*(y1(count)-y2(count)))>=25;
        if x1(count)>x2(count)
            temp=x1(count);
            x1(count)=x2(count);
            x2(count)=temp;
        end
        if y1(count)>y2(count)
            temp=y1(count);
            y1(count)=y2(count);
            y2(count)=temp;
        end   
        count=count+1;
    end
end

feature_selection = [x1, y1, x2, y2, layer];