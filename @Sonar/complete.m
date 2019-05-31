% Thu Jun 12 23:43:14 WIB 2014
% Karl Kastner, Berlin
%
% fill missing fields with NaN
%
% This programme is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This programme is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this programme.  If not, see <https://www.gnu.org/licenses/>.
%
%
function obj = complete(obj)
	fieldname_C = {
		'UpperLimit',
		'LowerLimit',
		'Depth',
		'WaterTemp',
		'Temp2',
		'Temp3',
		'WaterSpeed',
		'PositionX',
		'PositionY',
		'TopOfBottomDepth',
		'TimeOffset',
		'Speed',
		'Track',
		'Altitude',
		'alt_bottom'
	};	
	n = length(obj.time);
	for idx=1:length(fieldname_C)
		obj.(fieldname_C{idx})(end+1:n) = NaN;
	end % for idx
	fieldname_C = {
		'SurfaceValid',
		'SurfaceDepth',
		'DepthValid',
		'WaterTempValid',
		'Temp2Valid',
		'Temp3Valid',
		'WaterSpeedValid',
		'PositionValid',
		'TimeValid',
		'TopOfBottomValid',
		'ColumnIs50kHz',
		'SpeedTrackValid',
		'AltitudeValid',
	};
	for idx=1:length(fieldname_C)
		obj.(fieldname_C{idx})(end+1:n) = false;
	end % for idx

	% TODO, quick fix
	obj.wgs84.lat(end+1:n) = NaN;
	obj.wgs84.lon(end+1:n) = NaN;
	obj.utm.X(end+1:n) = NaN;
	obj.utm.Y(end+1:n) = NaN;
end % complete

