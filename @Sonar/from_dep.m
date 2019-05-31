% Mon Apr 21 11:07:57 WIB 2014
% Karl Kastner, Berlin
%
% read dep data into the slg-like object
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
function obj = from_dep(obj,dep)
		obj.time       = dep.time;
		obj.wgs84      = dep.wgs84;
		obj.utm        = dep.utm;
		obj.Depth      = dep.depth;
		obj.alt_bottom = dep.alt_bottom;

		% TODO DEP members, that are not in Slg
		% dep.dgps
		% dep.interp
		% dep.filt
		% dep.filename
		% dep.filenum
		% dep.sdx
		% dep.s
% TODO file specific variables of slg
%		header
%		headerlen
%		blocklen
%		quality
%		l
% TODO		ECHO
%		ptype = 'linear';
		l = length(dep.time);
		%obj.time(end+1:end+l) = obj2.time;
		%obj.wgs84.lat(end+1:end+l) = obj2.wgs84.lat;
		%obj.wgs84.lon(end+1:end+l) = obj2.wgs84.lon;
		%obj.utm.X(end+1:end+l) = obj2.utm.X;
		%obj.utm.Y(end+1:end+l) = obj2.utm.Y;
		% Lowrance features
		obj.UpperLimit       = NaN(l,1,'single');
		obj.LowerLimit       = NaN(l,1,'single');
		obj.DepthValid       = true(l,1);
%		obj.Depth = obj2.Depth;
		obj.WaterTempValid   = false(l,1);
		obj.WaterTemp        = NaN(l,1,'single');
		obj.Temp2Valid       = false(l,1);
		obj.Temp2            = NaN(l,1,'single');
		obj.Temp3Valid       = false(l,1);
		obj.Temp3            = NaN(l,1,'single');
		obj.WaterSpeedValid  = false(l,1);
		obj.WaterSpeed       = NaN(l,1,'single');
		% TODO inverse transformation to lowrance mercator
		obj.PositionValid    = false(l,1);;
		obj.PositionX        = zeros(l,1,'int32');
		obj.PositionY        = zeros(l,1,'int32');
		obj.SurfaceValid     = false(l,1);;
		obj.SurfaceDepth     = NaN(l,1,'single');;
		obj.TopOfBottomValid = false(l,1);;
		obj.TopOfBottomDepth = NaN(l,1,'single');;
		obj.ColumnIs50kHz    = false(l,1);;
		% TODO inverse transformation for time offset not yet implemented
		obj.TimeValid        = false(l,1);;
		obj.TimeOffset       = zeros(l,1,'int32');
		obj.SpeedTrackValid  = false(l,1);;
		obj.Speed            = NaN(l,1,'single');;
		obj.Track            = NaN(l,1,'single');;
		obj.AltitudeValid    = false(l,1);;
		obj.Altitude         = NaN(l,1,'single');;
end % from_dep

