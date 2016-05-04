function output=my_lorentzian_fit(p,x)
%if flag = 1 then use the lorentzian equation fitting function for the
%conductance values
%if flag = 2 then use the lorentzian equation fitting funvtion fot eh
%susceptance values
%the variable p contains 5 guess parameters
flag=1;
if flag==1%fitting for conductance data
    %Order of parameters in p is as follows
    %p(1): f0 maximum frequency
    %p(2): gamma0 dissipation
    %p(3): phi phse angle difference
    %p(4): Gmax maximum conductance
    %p(5): Offset value
    output= p(4).*((((x.^2).*((2.*p(2)).^2))./(((((p(1)).^2)-(x.^2)).^2)+...
        ((x.^2).*((2.*p(2)).^2)))).*cosd(p(3))-((((p(1)).^2-x.^2)).*x.*(2.*p(2)))./...
        (((((p(1)).^2)-(x.^2)).^2)+((x.^2).*((2.*p(2)).^2))).*sind(p(3)))+p(5);
elseif flag==2%fitting for the susceptance data
    %Order of parameters in p is as follows
    %p(1): f0 maximum frequency
    %p(2): gamma0 dissipation
    %p(3): phi phase angle difference
    %p(4): Gmax maximum conductance
    %p(5): Offset value
    output= p(4).*((((x.^2).*((2.*p(2)).^2))./(((((p(1)).^2)-(x.^2)).^2)+...
        ((x.^2).*((2.*p(2)).^2)))).*sind(p(3))-((((p(1)).^2-x.^2)).*x.*(2.*p(2)))./...
        (((((p(1)).^2)-(x.^2)).^2)+((x.^2).*((2.*p(2)).^2))).*cosd(p(3)))+p(5);
end%if flag==1
