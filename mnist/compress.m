function c = compress(g,qf)

% JPEG compression algorithm.
% 
% Input:
% g:	input image (24-bit RGB image) 
% qf:	quality factor (real number in (0,100])
% Output:
% c:    compressed image (24-bit RGB image)
%
% (c) Arttu Nieminen 2017

% Luminance quantisation table (Y)
QL = [16 11 10 16 24  40  51  61 ;%
      12 12 14 19 26  58  60  55 ;%
	  14 13 16 24 40  57  69  56 ;%
	  14 17 22 29 51  87  80  62 ;%
	  18 22 37 56 68  109 103 77 ;%
	  24 35 55 64 81  104 113 92 ;%
	  49 64 78 87 103 121 120 101;%
	  72 92 95 98 112 100 103 99 ;];

% Chrominance quantisation table (Cb,Cr)
QC = [17 18 24 47 99 99 99 99;%
	  18 21 26 66 99 99 99 99;%
	  24 26 56 99 99 99 99 99;%
	  47 66 99 99 99 99 99 99;%
	  99 99 99 99 99 99 99 99;%
	  99 99 99 99 99 99 99 99;%
	  99 99 99 99 99 99 99 99;%
	  99 99 99 99 99 99 99 99;];

% Compute quantisation matrices
if qf < 50
	sf = 50/qf;
else
	sf = 2-(qf/50);
end
sfQL = sf*QL;
sfQC = sf*QC;

% Image dimensions
h = size(g,1);
w = size(g,2);

% Preprocessing: R'G'B' -> Y'CbCr, shift values by -128
f = double(g);
r = f(:,:,1)/255;
g = f(:,:,2)/255;
b = f(:,:,3)/255;
y  =  0.299*r + 0.587*g +0.114*b;
cb =  -0.168736*r - 0.331264*g + 0.5*b;
cr = 0.5*r -0.418688*g - 0.081312*b;
Y  = 219*y - 112;	% luminance
Cb = 224*cb;		% chrominance red
Cr = 224*cr;		% chrominance blue
f = cat(3,Y,Cb,Cr);
re = f; % for decompressed image

% Downsampling: none

% Divide into 8x8 blocks and handle them separately
for i = 1:ceil(h/8)
	for j = 1:ceil(w/8)
		% Form 8x8 block (i,j)
		bij = f( (8*(i-1)+1):(min(8*(i-1)+8,h)) , (8*(j-1)+1):(min(8*(j-1)+8,w)) , :);
		h_bij = size(bij,1);
		w_bij = size(bij,2);
		if h_bij < 8 || w_bij < 8	% incomplete block -> complete with black pixels
			bij(:,:,1) = bij(:,:,1) + 112;
			bij(8,8,1) = 0;
			bij(:,:,1) = bij(:,:,1) - 112;
		end
		
		% Discrete Cosine Transform
		dct_y  = dct2(bij(:,:,1));
		dct_cb = dct2(bij(:,:,2));
		dct_cr = dct2(bij(:,:,3));
		
		% Quantisation
		q_y  = round(dct_y./(sfQL));
		q_cb = round(dct_cb./(sfQC));
		q_cr = round(dct_cr./(sfQC));
		
		% (Encoding and decoding not done)
		
		% De-quantisation
		re_dct_y  = q_y.*sfQL;
		re_dct_cb = q_cb.*sfQC;
		re_dct_cr = q_cr.*sfQC;
		
		% Inverse Discrete Cosine Transform
		re_bij = cat(3,idct2(re_dct_y),idct2(re_dct_cb),idct2(re_dct_cr));
		
		% Remove added pixels and put the block in its place
		re( (8*(i-1)+1):(min(8*(i-1)+8,h)) , (8*(j-1)+1):(min(8*(j-1)+8,w)) , :) = re_bij(1:h_bij,1:w_bij,:);
	end
end

% Y'CbCr -> R'G'B'
Y  = re(:,:,1);
Cb = re(:,:,2);
Cr = re(:,:,3);
y  = (Y+112)/219;
cb = Cb/224;
cr = Cr/224;
r = y + 1.402*cr;
g = y + -0.344136*cb - 0.714136*cr;
b = y + 1.772*cb;
c = uint8(cat(3,255*r,255*g,255*b));

end