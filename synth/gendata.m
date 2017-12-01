% Simulated annealing algorithm for improving JPEG image quality
%
% Generates fixed size model images from preprocessed image data
% by slicing them up into patches.
%
% (c) Arttu Nieminen 2017

dir1 = 'zigzag_rgb_orig'; % name of original data folder
dir2 = 'zigzag_rgb_data_32'; % name of model data folder
s = 32;             % fixed size (s x s) for model images
f = 'mod_img_';     % suffix for model image names
c = 0;              % counter for created model images

% Read original images
cd(dir1);
imagedata = dir('*.tif');
n = length(imagedata);
img = cell(1,n);
for i = 1:n
	img{i} = imread(imagedata(i).name);
end

% Slice original images and save into files
cd ..;
cd(dir2);
for i = 1:n
	d = img{i};
    h = size(d,1);
    w = size(d,2);
    j = 0;
    k = 0;
    while j+s < h
       while k+s < w
           c = c+1;
           imwrite(d(j+1:j+s,k+1:k+s,:),strcat(f,int2str(c),'.tif'),'tif');
           k = k+s;
       end
       k = 0;
       j = j+s;
    end    
end
cd ..;