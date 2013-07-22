function [X Pxx Yest] = EstimateDataJansen(Data,fs)


Y = Data;

% Dynamic variables
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Estimation Control variables
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Estimation Procedure Parameters
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Ds = 6; % Number of differential equations describing model, also the number of fast states to be estiamted

Dp = 2; % Number of parameters to be estimated, also refered to as slow states

Dk =1; %If set to 1 the mean of the stochastic input will be estimated % Note that if Input_mean_variation is not zero than Dk should be set to one to allow tracking of the input mean

Dx = Ds+Dp+Dk; % Number of dimensions of augmented state matrix, Note that estimated parameters and inputs are now considered to be 'slow states' in the estimation procedure

Dy =1; % Number of observable outputs from the simulation

EstStart = 0; % Specify the duration after simulation start when estimation should start. This allows removal of all transients.

number_of_sigma = 4; % Number of standard deviations from mean. 4 accounts for 99.73 percent of points.

kappa =1; % Varibale used to define the relative contribution of the mean on the propogation of states

Base_state_uncertainty = 2e-3; % Inherent state uncertainty due to model error

Variable_state_uncertainty = 0;%5e-3; % 1e-3 Uncertianty due to stochastic input

Base_parameter_uncertainty = 2e-3; % Inherent parameter uncertainty due to model error

Variable_parameter_uncertainty = 0;%5e-3;  % Uncertianty due parameters varying in time

Base_input_uncertainty = 2e-3; % Inherent parameter uncertainty due to model error

Variable_input_uncertainty =0;%5e-3; % Uncertianty due varying input mean, Set to zero if the input mean is not varying

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

NoiseIn = 1e-4;% Base 1e-2

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
while ((init<10)&&((init==0) || ((p==Number_of_observations) && ((X(Ds+Dk+1,p) <0) || (X(Ds+Dk+2,p) <0)|| (X(Ds+Dk+3,p) <0)))))
init=init+1;
Initialise_Parameters_and_covariances_GUI

%%

% UKF algorithm
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

for p =1:Number_of_observations
    
    [Sigma(:,:,p) err] = Unscented_transform_GUI(Dx,Pxx(:,:,p),X(:,p),kappa);
    if (err ==1)
        break
    end
%     if Dp>0
%         SigmaT = Sigma(Ds+Dk:Dx,:,p);
%         SigmaT(SigmaT<0) = 0;
%         Sigma(Ds+Dk:Dx,:,p) = SigmaT;
%     end
    
    for k = 1:Sigma_points
        if Dp==3
            gain = [Sigma(Ds+Dk+1,k,p) Sigma(Ds+Dk+2,k,p) Sigma(Ds+Dk+3,k,p)];
        elseif Dp ==2
            gain = [Sigma(Ds+Dk+1,k,p) Sigma(Ds+Dk+2,k,p) G];
        elseif Dp==1
            gain = [Sigma(Ds+Dk+1,k,p) B G];
        end
        
        if Dk ==1
%             if (LimitEst ==1)
%                 if Sigma(Ds+1,k,p) > (frequency_limits(2))
%                     Sigma(Ds+1,k,p) = frequency_limits(2);
%                 elseif Sigma(Ds+1,k,p) < (frequency_limits(1))
%                     Sigma(Ds+1,k,p) = frequency_limits(1);
%                 end
%             end
            Input_var = Sigma(Ds+1,k,p);
        else
            Input_var = Input_mean;
        end
        
        [Xout(:,k,p) Yout(:,k,p)] = WNM1(Sigma(:,k,p),dt,Input_var, gain, tcon,C);
        
    end
    
    [ExpX(:,p) ExpY(:,p) Pxxn Pxyn Pyyn] = Expectation(Xout(:,:,p), Dx, Yout(:,:,p), 1,kappa);
    
    Pyyn = Pyyn +R;
    %
    Pxxn = Pxxn + Q;
    
    [X(:,p+1) Pxx(:,:,p+1)] = Kalman(ExpX(:,p), ExpY(:,p), Y(p), Pxxn, Pxyn, Pyyn);
end
end

Yest = X(2,:)-C(4)*X(3,:)-X(4,:);
%%




