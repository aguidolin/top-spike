function BC_interp = BC_rescale_edgedensity(BC, xmax)
%Rescale Betti curve for plot against edge density (instead of edge
%number).
%The maximum value of x-axis (xmax) is set by default to 1210 
%(it corresponds to edge density 0.6 on a graph with 64 vertices)
%Linear interpolation is used to determine the new y-values of the Betti
%curves.
%
% Andrea Guidolin (11 Nov 2021)

if nargin < 2
    xmax = 1210;
end

xmax_original = size(BC,1);

x_original = 1 : size(BC,1);

x_rescaled = (xmax/xmax_original)*x_original;

x_interp = 1 : xmax;

%'extrap' solves the problem of 'NaN' values returned for out-of-range x-values
BC_interp = interp1(x_rescaled,BC,x_interp,'linear','extrap');

end
