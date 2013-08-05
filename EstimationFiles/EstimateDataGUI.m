function [X Pxx PxxT] = EstimateDataGUI(Data,fs,Initialise,Channel,Start)


addpath(genpath('../../UKFFinal'));

system_dependent('setprecision',24);

Y = Data;

User_defined_parameters_GUI;

Dx = Ds+Dp+Dk; % Number of dimensions of augmented state matrix, Note that estimated parameters and inputs are now considered to be 'slow states' in the estimation procedure[

Estimation_Type = 'EstimationResults\Data';
dt = 1/fs;

% Data
% ~~~~~~~~~~~~~~~~

if filter_simulation
    band_coeff = filtercoeff(lowcutoff,highcutoff,fs);
    Y = filtfilt1(band_coeff,1,Y);
end

if Normalise_data
    Y = (Y-mean(Y))/std(Y);
end

% Physiological range of Model gains
% ~~~~~~~~~~~~~~~~~

Max_A =10;
Min_A =0;
Max_B =40;
Min_B =0;
Max_G =40;
Min_G =0;

Max = [Max_A, Max_B, Max_G];
Min = [Min_A, Min_B, Min_G];

% Model Parameters
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


% Static Variables
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% ~~~~~~~~~~~
EstimationVariables_Data_GUI;

if Initialise 
    load TemporaryInit StateEstimatesT PxxT Scale
    X(:,1) = StateEstimatesT(:,Channel);
    Pxx(:,1) = diag(PxxT(:,:,Channel));
    PxxT = PxxT(:,:,Channel);
    load DataScale Scale
    Y = Y*Scale;
else
    [Y Scale] =  Normalise(Y,Max_sim_voltage,fs,10); 
    save DataScale Scale
end

% for q = 1:Simulation_number
init =0;
condition =1;
err=0;
while condition
    init=init+1;
    conditionT = init<Reinitialise_parameters_attempts;
    if (Initialise ==0 || err)
    Initialise_parameters_Data;
    end
    
    %%
    
    % UKF algorithm
    % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    for p =1:Number_of_observations
        [Sigma(:,:,p) err] = Unscented_transform(Dx,PxxT,X(:,p),kappa);
        if (err ==1)
            break
        end
        
        %                 if (LimitEst ==1)
        % %                     for j = 1:Dp
        % %                         if (Sigma(Ds+Dk+j,:,p) <0) % Check if parameter breaches physiological range
        % %                             Sigma(Ds+Dk+j,:,p) =0;
        % %                         end
        % %                     end
        %                 end
        
        if Dp==3
            gain = [Sigma(Ds+Dk+1,:,p); Sigma(Ds+Dk+2,:,p); Sigma(Ds+Dk+3,:,p)];
        elseif Dp ==2
            gain = [Sigma(Ds+Dk+1,:,p); Sigma(Ds+Dk+2,:,p); ones(1,size(Sigma,2))*G];
        elseif Dp==1
            gain = [Sigma(Ds+Dk+1,k,p); ones(1,size(Sigma,2))*B; ones(1,size(Sigma,2))*G];
        end
        
        if Dk ==1
            %                     if (LimitEst ==1)
            %                         if (Sigma(Ds+1,k,p) < 0)
            %                             Sigma(Ds+1,k,p) = 0;
            %                         end
            %                     end
            Input_var = Sigma(Ds+1,:,p);
        else
            Input_var = Input_mean;
        end
        
        [Xout(:,:,p) Yout(:,:,p)] = WNM(Sigma(:,:,p),dt,Input_var, gain, tcon,C);
        
        
        [ExpX(:,p) ExpY(:,p) Pxxn Pxyn Pyyn] = Expectation(Xout(:,:,p), Dx, Yout(:,:,p), 1,kappa);
        
        Pyyn = Pyyn +R;
        %
        Pxxn = Pxxn + Q;
        
        [X(:,p+1) PxxT] = Kalman(ExpX(:,p), ExpY(:,p), Y(p), Pxxn, Pxyn, Pyyn);
        
        Pxx(:,p+1) = diag(PxxT);
    end
    conditionT1 = ((X(Ds+Dk+1,end) <0) || (X(Ds+Dk+2,end) <0) ||(X(Ds+Dk+3,end) <0));
    condition = ((conditionT && conditionT1) || (err&&init<5));
end

%     if (Simulation_number ~=1)
%         if q ==1
%             X_Multi = zeros(floor(size(X,2)/Decimate)+1,Dp+Dk,Simulation_number);
%             Pxx_Multi = zeros(floor(size(X,2)/Decimate)+1,Dp+Dk,Simulation_number);
%         end
%         X_Multi(:,:,q) = X(Ds+1:Ds+Dp+Dk,1:500:end)';
%         for k =1:Dk+Dp
%             Pxx_Multi(:,k,q) = squeeze(Pxx(k,1:500:end));
%         end
%             else 
%         X_Multi =0;
%         Pxx_Multi =0;
%     end
% end % End Simulation_nuumber loop

Generate_figures_data;

if fig_save
    
    Figure_handling_Data;
    
end
% if Simulation_number>1
%     Generate_figures_multi_data;
%     if fig_save
%         
%         Figure_handling_multi_Data;
%         
%     end
% end

%%




