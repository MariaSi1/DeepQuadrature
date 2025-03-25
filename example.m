%This code performes the exemplary analysis with the use 
% of DeepQuadrature neural network
% source: 
% M. Cywińska, M. Rogalski, F. Brzeski, K. Patorski, M. Trusiak, 
% "DeepQuadrature: universal convolutional neural network 
% enlarging space-bandwidth product 
% in single-shot fringe pattern optical metrology" 
% J. Phys. Photonics https://doi.org/10.1088/2515-7647/adc219 
%
%
% for questions contact:
% maria.cywinska@pw.edu.pl


clear all;
close all;


%exemplary data (may be replaced by other/user's data - 
% - the only requirement is preprocessing)
% for recommended preprocessing path for your data 
% see supplementary material of the paper and
% uVID prefiltration (M. Cywińska,et al., Opt. Express 27 (2019)).

% load("test_dataset.mat") %simulated dataset Fig.5 and Fig. 5 
% period=170; % period change range in simulated dataset -> period=4:2:170
% ii=period/2-1;

% load("phase_test.mat"), ii=1; %phase test group J sample (Fig. 7), reference_background is phase calculated for data without a sample

 load("HeLa1.mat"), ii=1; %HeLa cells (Fig. 8)

% load("HeLa2.mat"), ii=1; %HeLa cells (Fig. 9)

%Trained DeepQuadrature model
load("DeepQuadratureNet.mat")

%preparation of the trained model to work with any data size
lgraph=layerGraph(network);
lgraph = removeLayers(lgraph,["regressionoutput"]);
dlnet=dlnetwork(lgraph);

%network prediction
dlX = dlarray(input_fringes(:,:,:,ii), 'SSCB');
[Y] = forward(dlnet,dlX,'Outputs','relu1_out');
output_net=extractdata(Y);

%wrapped phase calculation
sine=(double(output_net)-0.5)*2;
cosine=(input_fringes(:,:,1,ii)-0.5)*2;
wr=atan2(cosine,sine);

%unwrapping (M. A. Herráez, et al., Appl. Opt. 41 (2002))
unw=double(Miguel_2D_unwrapper(single(wr)));

%plane-fitting
out=plane(unw);
