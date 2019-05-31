% Fri Nov 22 16:45:08 UTC 2013
% Karl Kästner, Berlin
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
classdef DGPS < handle
	properties
		% sample: 1xn sequential sample number
		sample;
		% time : 1xn time of sample
		time;
		% lat: 1xn latitude
		% lon: 1xn longitude
		wgs84 = struct('lat', [], 'lon', []);
		% alt: 1xn altitude
		alt;
		err;
		ierr;
	end % properties
	methods
		% constructor
		function obj = DGPS(filename)
			% default construction
			if (nargin() < 1)
				return;
			end

			% read in and tokenise file in one go
			fid = fopen(filename,'r');
			if (-1 == fid)
				error('failed to open file');
			end
			C = textscan(fid,'%s','delimiter',',');
			fclose(fid);
			m = 28;
			% convert date fields to matlab internal time value
		%	datestr  = [C{1}{7:m:end}];
		%	timestr  = [C{1}{8:m:end}];
		%	datestr  = reshape(datestr,10,[])';
		%	timestr  = reshape(timestr,12,[])';
		%	str = [datestr timestr];
		%	obj.time = datenum(str,'"mm/dd/yy""HH:MM:SSam"');
			str = [C{1}{24:m:end}];
			str = reshape(str,19,[])';
			obj.time = datenum(str,'mm/dd/yy HH:MM:SSam');
			% convert value fields to number
			obj.wgs84.lat  = cellfun(@str2num, {C{1}{25:m:end}});
			obj.wgs84.lon  = cellfun(@str2num, {C{1}{26:m:end}});
			obj.alt  = cellfun(@str2num, {C{1}{28:m:end}});
			% sort the time steps and discard duplicates
			[obj.time tdx] = unique(obj.time);
			obj.wgs84.lat  = obj.wgs84.lat(tdx);
			obj.wgs84.lon  = obj.wgs84.lon(tdx);
			obj.alt  = obj.alt(tdx);
		end % constructor()
	end % methods
end % classdef DGPS

