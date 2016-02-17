I=imread('F:\History Docs\Master 1st\16720 Computer Vision\homework1\dat\airport\sun_ahigtnhmsjrkayvw.jpg');
imshow(I);
filterBank=createFilterBank();
wordMap=getVisualWords(I, filterBank, dictionary);