% Mon Apr 21 11:15:18 WIB 2014
% Karl Kastner, Berlin
%
% concatenate the data of two slg objects
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
% TODO optionally cat ECHO
function obj = cat(obj,obj2)
% slg-file specific scalars, not yet supported 
%	header
%	headerlen
%	blocklen
%	quality
%	l
	l1 = length(obj.time);
	l2 = length(obj2.time);
	if (l2 > 0)

	obj.time(l1+1:l1+l2) = obj2.time;
	obj.wgs84.lat(l1+1:l1+l2) = obj2.wgs84.lat;
	obj.wgs84.lon(l1+1:l1+l2) = obj2.wgs84.lon;
	obj.utm.X(l1+1:l1+l2) = obj2.utm.X;
	obj.utm.Y(l1+1:l1+l2) = obj2.utm.Y;
	obj.alt_bottom(l1+1:l1+l2) = obj2.alt_bottom;
	% Lowrance features
	
	for idx=1:length(obj.datafield_C)
		if (isempty(obj2.(field_C{idx})))
			obj.(field_C{idx})(l1+1:l1+l2) = NaN;
		else
			obj.(field_C{idx})(l1+1:l1+l2) = obj2.(field_C{idx});
		end
	end
	end
end % cat

