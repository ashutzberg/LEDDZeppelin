function [img] = getTagImage(imageSub)

image = receive(imageSub, 10);
img = readImage(image);
% imshow(img);
