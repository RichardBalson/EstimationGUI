function [X Pxx Yest] = EstimateData(Data,fs, Initialise,Channel)
if Initialise 
    load TemporaryInit StateEstimatesT PxxT 
end

Y = Data;

% Dynamic variables
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Estimation Control variables
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Estimation Procedure Parameters
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Ds = 8; % Number of differential equations describing model, also the number of fast states to be estiamted

Dp = 3; % Number of parameters to be estimated, also refered to as slow states

Dk =0; %If set to 1 the mean of the stochastic input will be estimated % Note that if Input_mean_variation is not zero than Dk should be set to one to allow tracking of the input mean

Dx = Ds+Dp+Dk; % Number of dimensions of augmented state matrix, Note that estimated parameters and inputs are now considered to be 'slow states' in the estimation procedure

Dy =1; % Number of observable outputs from the simulation

EstStart = 0; % Specify the duration after simulation start when estimation should start. This allows removal of all transients.

number_of_sigma = 4; % Number of standard deviations from mean. 4 accounts for 99.73 percent of points.

kappa =1; % Varibale used to define the relative contribution of the mean on the propogation of states

Base_state_uncertainty = 1e-3; % Inherent state uncertainty due to model error

Variable_state_uncertainty =0; % 1e-3 Uncertianty due to stochastic input

Base_parameter_uncertainty = 1e-3; % Inherent parameter uncertainty due to model error

Variable_parameter_uncertainty =0;  % Uncertianty due parameters varying in time

Base_input_uncertainty = 1e-3; % Inherent parameter uncertainty due to model error

Variable_input_uncertainty =0; % Uncertianty due varying input mean, Set to zero if the input mean is not varying

NoiseIn = 1e-3;% Base 1e-2

% Image handling parameters
% ~~~~~~~~~~~~~~~~~~~~~~~

Estimation_Type = 'Detected_Seizures'; % Estimation Type is an indication of what estimation is being performed for, here Gauss indicates that all staes are initialised as realisations from a Gaussian distribution

fig_save =1; % Save figures as .fig for future use

Print =0; % If Print = 1 figures will print to pdf

PrintP =1; % If printP =1 print only parameter plots

Image_handling_model_output=[0;0];

plot_uncertainty =1; % Plot covariance of all states

Image_handling_states = [0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0]; % Here a decision is made whether to plot specific states,
% if the value is one the relevant figure is plotted, otherwise it is not.
% The columns indicate the state to plot and the rows indicate whether the whole simulation or a zoomed in ploted should be plotted.
% Column one corresponds with state 1 and so forth.
Image_handling_inputs = [0 0 0 0;0 0 0 0];  % Here a decision is made whether to plot specific states,
% if the value is one the relevant figure is plotted, otherwise it is not.
% The columns indicate the state to plot and the rows indicate whether the whole simulation or a zoomed in ploted should be plotted.
% Here column 1-4 are Vp,Ve,Vsi and Vfi respectively.

Image_handling_firing_rates = [0 0 0 0]; % Here a decision is made whether to plot specific states,
% if the value is one the relevant figure is plotted, otherwise it is not.
% The columns indicate the firing rate to plot. this is a three image plot where the input potential population firing rate and output potential are plotted.
% Here column 1-4 are Vp,Ve,Vsi and Vfi respectively.

Image_handling_multi = [1 1 1 0;0 0 0 0];%  % Here a decision is made whether to plot specific states,
% if the value is one the relevant figure is plotted, otherwise it is not.
% The columns indicate the figures to be plotted.
% Here column 1-4 are for all the model states, all the model states inputs, all the model parameters and all the model parameters including the input mean.

% Zoom parameters (seconds)
% ~~~~~~~~~~~~~~~~~

tstart =0; % Starting time for zoom

zoom = 2; % Duration of zoom

% Data
% ~~~~~~~~~~~~~~~~

limit = length(Data); % Set limit on amount of points used for estimation

frequency_limits = [30 150];

% Model Parameters
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Con = 135; % Connectivity constant, used to specify connectivty between neuronal types

C= [Con; 0.8*Con; 0.25*Con; 0.25*Con; 0.3*Con; 0.1*Con; 0.8*Con]; % Connectivity Constants for all populations

% Input noise limits
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Units Hz
% ~~~~~~~~~~~~~

min_frequency = 30; % Minimum noise firing rate

max_frequency = 150; % Maximum noise input firing rate

frequency_limits = [min_frequency max_frequency];

a =100;             %Excitatory time constant
b =30;              %Slow inhibitory time constant original b=50
g =350;             %Fast inhibitory time constant g =500

tcon = [a b g]; % Specify reciprocal of the time constants for simulation

% Physiological range of Model gains
% ~~~~~~~~~~~~~~~~~

Max_A =7;
Min_A =3;
Max_B =40;
Min_B =0;
Max_G =40;
Min_G =0;

Max = [Max_A, Max_B, Max_G];
Min = [Min_A, Min_B, Min_G];

% Static Variables
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% ~~~~~~~~~~~
Static_variables_estimation_GUI;
p = Number_of_observations;
init=0;
    condition =1;
    while condition
    init=init+1
    conditionT = init<2;
    Initialise_Parameters_and_covariances_GUI
    
    %%
    
    % UKF algorithm
    % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    for p =1:Number_of_observations
        
        [Sigma(:,:,p) err] = Unscented_transform(Dx,Pxx(:,:,p),X(:,p),kappa);
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
        
        [X(:,p+1) Pxx(:,:,p+1)] = Kalman(ExpX(:,p), ExpY(:,p), Y(p), Pxxn, Pxyn, Pyyn);
    end
        conditionT1 = ((X(Ds+Dk+1,end) <0) || (X(Ds+Dk+2,end) <0) ||(X(Ds+Dk+3,end) <0));
        condition = conditionT && conditionT1;
end


Yest = X(2,:)-C(4)*X(3,:)-X(4,:);
%%

figure('name','exc')
plot(Yest);
hold on
plot(X(9,:),'r')
figure('name','Sinh')
plot(Yest);
hold on
plot(X(10,:),'r')
figure('name','FInh')
plot(Yest);
hold on
plot(X(11,:),'r')



