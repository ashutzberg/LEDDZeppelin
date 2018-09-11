% parse data from folder
% file name indicates label for that image

% extract features

% SVM classifier on images
% X is the image data/features and y is the labels
clf = fitcsvm(X,y)
% imgs is the image data/features and bag is the labels
clf = trainImageCategoryClassifier(imgs, bag)
% train

% test