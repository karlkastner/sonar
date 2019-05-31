% 2016-09-23 19:34:38.211324812 +0200
% Karl Kastner, Berlin
% 
% convert the data into SI units
%
% This programme is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This programme is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this programme. If not, see <https://www.gnu.org/licenses/>.
%
% TODO the scaling of values is incomplete
function obj = to_metric(obj,t0)
	% scale time to number of days
	obj.time             = t0 + obj.days_per_millisec*double(obj.TimeOffset);

	% scale data to metric units
	obj.Depth            = obj.metre_per_feet*obj.Depth;
	obj.UpperLimit       = obj.metre_per_feet*obj.UpperLimit;
	obj.LowerLimit       = obj.metre_per_feet*obj.LowerLimit;
	obj.TopOfBottomDepth = obj.metre_per_feet*obj.TopOfBottomDepth;
	obj.SurfaceDepth     = obj.metre_per_feet*obj.SurfaceDepth;

	% scale velocity into metric units
	obj.Speed = obj.metre_per_second_per_knot * obj.Speed;
end % to_metric

