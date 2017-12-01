% Simulated annealing algorithm for improving JPEG image quality.
%
% This program was made for my Bachelor's thesis.
% Because the thesis was written in Finnish, 
% Finnish is also used in the program outputs.
% The source code is otherwise written and commented using English.
%
% (c) Arttu Nieminen 2017
%
% The data are from the MNIST database of handwritten digits, 
% downloaded from http://yann.lecun.com/exdb/mnist/

close all;
clear all;

% Save console output to file
diary('mnist-output.txt');

% Program parameters
qf = 40;                % quality factor
b = 4;                  % block size bxb pixels
n_chains = 500;         % number of Markov chains
min_acc = 1000;         % minimum number of accepted states in a chain
max_pro = 10000;        % maximum number of proposed states in a chain
n_accrate = 100;        % number of recent proposals used to compute acceptance rate
alpha = 0.95;           % decrement coefficient for temperature
seed = 42;              % seed for RNG; for reproducibility

% Initialise random number generator
rng(seed,'twister');

% Load data
fprintf('Ladataan dataa... ');
t0 = 35.0; % initial temperature
t1 = 1.0;
t2 = 0.2;
n_img = 500;
file = fopen('train-images-idx3-ubyte'); % MNIST data
x = fread(file,16+(n_img*28*28));
fclose(file);
x = x(17:end);
x = reshape(x,28*28,n_img)';
img = cell(1,n_img);
for i = 1:n_img
    imgi = reshape(255-uint8(x(i,:)),[28,28])';
    img{i} = cat(3,imgi,imgi,imgi);
end
fprintf('Ladattu.\n');

% Original image
o = img{n_img};
n_img = n_img - 1;

% Measurement
m = compress(o,qf);
err_m = sqrt(diffnorm(o,m));    % L2 norm of measurement
[ssim_m,~] = ssim(o,m);         % SSIM of measurement

% Initialise state
t = t0;                         % initial temperature
s0 = randomstate(m,img,b);      % initial state
e0 = energy(s0,m,qf);           % initial energy
s = s0;
e = e0;
err_s = sqrt(diffnorm(o,s));    % L2 norm of state
[ssim_s,~] = ssim(o,s);         % SSIM of state
s_best = s;
e_best = e;
n_pro = 0;                      % # of proposed states
n_acc = 0;                      % # of accepted states
n_rej = 0;                      % # of consecutive rejected states
c = 0;                          % index of current chain
err_eoc = NaN(1,n_chains);      % end-of-chain L2 norm
ssim_eoc = NaN(1,n_chains);     % end-of-chain SSIM

% Initialise acceptance rate
accrate = NaN;

% Display original, measurement, current state 
figure(1)
subplot(2,3,1), subimage(o);
str_o = {'Alkuperäinen',' ',' '};
title(str_o);
set(gca,'Xtick',[]);
set(gca,'Ytick',[]);
axis equal;
subplot(2,3,2), subimage(m);
str_m = {'Pakattu',strcat('(',num2str(err_m),')'),strcat('(',num2str(ssim_m),')')};
title(str_m);
set(gca,'Xtick',[]);
set(gca,'Ytick',[]);
axis equal;
subplot(2,3,3), subimage(s);
str_s = {'Tila',strcat('(',num2str(err_s),')'),strcat('(',num2str(ssim_s),')')};
title(str_s);
set(gca,'Xtick',[]);
set(gca,'Ytick',[]);
axis equal;
str = {['Ketju nro ' num2str(c)],['Lämpötila: ' num2str(t)],['Ehdokastiloja: ' num2str(n_pro)],['Hyväksyttyjä ehdokastiloja: ' num2str(n_acc)],['Hyväksyttyjen osuus: ' num2str(accrate)]};
ax = subplot(2,3,[4 5 6]);
info = text(0.5,0.5,str);
info.HorizontalAlignment = 'center';
info.FontSize = 11;  
set(ax,'visible','off');

% Chains
for c = 1:n_chains
    
    % Initialise chain
    n_pro = 0;
    n_acc = 0;
    accrate = NaN;
    compute_accrate = false;
    ind_accrate = 1;
    decs = zeros(1,n_accrate);
    
    % Start chain
    while n_acc < min_acc && n_pro < max_pro
       
        % Generate a new proposal
        [s_new,cb_old,cb_new,cb_m] = candidate(s,m,img,b);
        delta_e = energychange(cb_old,cb_new,cb_m,qf);
        e_new = e + delta_e;
                
        % Accept or reject
        p = acceptprob(delta_e,t);
        accepted = p >= rand;
        if accepted
            % Update best
            if e_new < e_best
                s_best = s_new;
                e_best = e_new;
            end
            % Update state
            s = s_new;
            e = e_new;
            err_s = sqrt(diffnorm(o,s));
            [ssim_s,~] = ssim(o,s);
            n_acc = n_acc + 1;
            n_red = 0;
            % Update figure
            subplot(2,3,3), subimage(s);
            str_s = {'Tila',strcat('(',num2str(err_s),')'),strcat('(',num2str(ssim_s),')')};
            title(str_s);
            set(gca,'Xtick',[]);
            set(gca,'Ytick',[]);
            axis equal;
        else
            n_rej = n_rej + 1;
        end
        
        % Update chain statistics
        n_pro = n_pro + 1;
        decs(ind_accrate) = accepted;
        if ind_accrate == n_accrate
            compute_accrate = true;
        end
        if compute_accrate
            accrate = mean(decs);
        end
        ind_accrate = nextind(ind_accrate,n_accrate);
        
        % Update figure
        delete(info)
        str = {['Ketju nro ' num2str(c)],['Lämpötila: ' num2str(t)],['Ehdotettuja tiloja: ' num2str(n_pro)],['Hyväksyttyjä tiloja: ' num2str(n_acc)],['Hyväksyttyjen osuus: ' num2str(accrate)]};
        ax = subplot(2,3,[4 5 6]);
        info = text(0.5,0.5,str);
        info.HorizontalAlignment = 'center';
        info.FontSize = 11;  
        set(ax,'visible','off');
        drawnow;
    end
    
    % Save L2 norm and SSIM at the end of the chain
    err_eoc(c) = sqrt(diffnorm(s,o));
    [ssim_eoc(c),~] = ssim(s,o);
    
    % Update temperature and possibly block size
    t = alpha*t;
    if t < t1
        b = 2;
    end
    if t < t2
        b = 1;
    end
    
end

% Evaluate error
fprintf('Tulokset:\n\n');
err_meas = sqrt(diffnorm(m,o));
err_init = sqrt(diffnorm(s0,o));
err_final = sqrt(diffnorm(s,o));
err_best = sqrt(diffnorm(s_best,o));
fprintf('Erotuksen L2 normi pakatun ja alkuperäisen kuvan välillä: %f\n',err_meas);
fprintf('Erotuksen L2 normi alkutilan ja alkuperäisen kuvan välillä: %f\n',err_init);
fprintf('Erotuksen L2 normi lopputilan ja alkuperäisen kuvan välillä: %f\n',err_final);
fprintf('Erotuksen L2 normi parhaan tilan ja alkuperäisen kuvan välillä: %f\n',err_best);
fprintf('\n');

[ssim_meas,~] = ssim(m,o);
[ssim_init,~] = ssim(s0,o);
[ssim_final,~] = ssim(s,o);
[ssim_best,~] = ssim(s_best,o);
fprintf('SSIM pakatun ja alkuperäisen kuvan välillä: %f\n',ssim_meas);
fprintf('SSIM alkutilan ja alkuperäisen kuvan välillä: %f\n',ssim_init);
fprintf('SSIM lopputilan ja alkuperäisen kuvan välillä: %f\n',ssim_final);
fprintf('SSIM parhaan tilan ja alkuperäisen kuvan välillä: %f\n',ssim_best);
fprintf('\n');

e_meas = energy(m,m,qf);
e_init = e0;
e_final = energy(s,m,qf);
fprintf('Pakatun kuvan energia: %f\n',e_meas);
fprintf('Alkutilan energia: %f\n',e_init);
fprintf('Lopputilan energia: %f\n',e_final);
fprintf('Parhaan tilan energia: %f\n',e_best);

% Save results to file for plotting

% Final state of the algorithm progress plot
finals = struct('f_o',o,'f_m',m,'f_s',s,'f_sb',s_best,'f_ot',{str_o},'f_mt',{str_m},'f_st',{str_s},'f_info',{str});
save('mnist-final.mat', 'finals');

% End-of-chain errors
save('mnist-eoc-l2.mat','err_eoc');
save('mnist-eoc-ssim.mat','ssim_eoc');

% Window showing algorithm progress and final state
print('mnist-plot','-dpng'); % not optimised

diary off;