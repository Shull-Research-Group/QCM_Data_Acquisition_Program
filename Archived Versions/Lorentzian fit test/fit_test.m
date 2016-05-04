%Chyi-Huey Joshua Yeh
%This MATLAB script tests the different settings that can be manipulated
%for the curve-fitting functions and compares the different ways to fit
%curves
clear all; clc;
%load the test spectra
load('fit_test_spectra.mat');

%extract out data from spectra variable: test_spectra
freq_data=test_spectra(:,1);
conductance=test_spectra(:,2);
susceptance=test_spectra(:,3);

%plot the raw spectra data
figure(1);clf(figure(1));
a1=axes;
plot(freq_data,conductance,'bo','markersize',6);
hold on;
plot(freq_data,susceptance,'ro','markersize',6);
xlabel('Frequency (Hz)','fontweight','bold');
ylabel('mSiemans','fontweight','bold');

%do the fitting with lsqcurvefit function using the levenberg-marquardt
%method
%defind lower and upper bounds for the parameters
lb=[-Inf -Inf -inf -Inf -inf];
ub=[Inf Inf Inf Inf Inf];
error=0.003;
%set initial guess values
x0=zeros(1,5);
[max_conductance0,location_index]=findpeaks(conductance,'minpeakheight',3);
x0(1)=freq_data(location_index);
x0(4)=max_conductance0;
temp=conductance-x0(4)/2;
find(temp==min(abs(temp)),1);
gamma0=abs(x0(1)-freq_data(ans))*2;
x0(2)=gamma0;
%set options settings for the curve fitting process
options=optimset('display','on','tolfun',1e-10,'tolx',1e-10,'plotfcns',@optimplotresnorm,'maxiter',10000000000000,'findifftype','central','maxfuneval',10000);
[parameters resnorm residual exitflag]=lsqcurvefit(@my_lorentzian_fit,x0,freq_data(),conductance(),lb,ub,options);%use lsqcurvefit function to fit the spectra data to a Lorentz curve
fitted_cond=my_lorentzian_fit(parameters,freq_data());
text('parent',a1,'units','normalized','position',[0.1 0.9 1],'string',['X^2 = ',num2str(resnorm./((error^2)*199))]);
%plot the fitted y values
figure(1);
plot(a1,freq_data(),fitted_cond,'k-','linewidth',1.5);
legend('Conductance','Susceptance','Fitted Lorentzian function');