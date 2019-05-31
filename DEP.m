% Fri Nov 22 17:48:01 UTC 2013
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
%
% TODO split this class in two parts
% 1) DEP / DGPS loading
% 2) bathymetry processing specific functions
%
% process echo sounder data
classdef DEP < handle
	properties
		% time  : nx1 sample time
		time;

		% wgs84.lat   : nx1 sample wgs84.latitude
		% wgs84.lon   : nx1 sample wgs84.longitude
		wgs84 = struct('lat', [], 'lon', []);
		utm   = struct('X', [], 'Y', []);

		% depth : nx1 sample depth
		depth;

		% alt_bottom : nx1 altitude of bottom above the sea level
		alt_bottom;

		% corresponding coordinates from the DGPS device
		dgps   = DGPS();

		% coordinates interpowgs84.lated to sub-second intervals
		interp = struct('lat',[],'lon',[],'err',[]);

		% filtered bathymetry data
		filt;

		% input file names to create the object
		filename;

		% number of the input file of sample
		fnum;

		% sparsification index
		sdx;
		
		s;
		ptype = 'linear';
	end % properties
	methods
		% constructor
		function obj = DEP(filename)
			if (iscell(filename))
				% sort input files by start time
				filename = sortfiles(filename);
				obj.filename = filename;
				% read in files sequentially
				for idx=1:length(filename)
					try
						obj.DEP_(filename{idx},idx);
					catch e
						disp(filename{idx});
						disp(e)
					end
				end % for idx
			else
				% single file only
				obj.filename = filename;
				obj.DEP_(filename,1);
			end
			% sort time and discard multiple value
			% TODO avarage
			[obj.time, tdx] = unique(obj.time);
			obj.wgs84.lat   = obj.wgs84.lat(tdx);
			obj.wgs84.lon   = obj.wgs84.lon(tdx);
			obj.depth = obj.depth(tdx);
			% convert wgs84.lat wgs84.lon to utm
			[obj.utm.X, obj.utm.Y] = latlon2utm(obj.wgs84.lat, obj.wgs84.lon, '49M');
		end % constructor

		% load echo sounder data from an individual file
		function obj = DEP_(obj,filename,fnum)
			% read in the entire file
			fid = fopen(filename,'r');
			if (-1 == fid)
				fprintf('error: failed to open file\n');
				error('failed to open file');
			end
			str = fread(fid,'*char');
			fclose(fid);
			% split lines into cell array
			C = textscan(str,'%s','delimiter',',');
			% read in the time
			datestr = [C{1}{1:8:end}];
			timestr = [C{1}{2:8:end}];
			datestr = reshape(datestr,8,[])';
			timestr = reshape(timestr,11,[])';
			% append separation character
			datestr(:,end+1) = ' ';
			% append zero for miliseconds
			timestr(:,end+1) = '0';
			str     = [datestr timestr];
			% convert date to matlab internal time format
			time = datenum(str,'mm-dd-yy HH:MM:SS.FFF');

			% read depth and position data
			val = dlmread(filename, ',', 0, 2);
			obj.time  = [obj.time;  time];
			obj.wgs84.lat   = [obj.wgs84.lat;   val(:,1)];
			obj.wgs84.lon   = [obj.wgs84.lon;   val(:,2)];
			obj.depth = [obj.depth; val(:,6)];

		end % constructor
		% interpowgs84.lates coordinates to sub-second intervals,
		% as depth is sampled every 0.1 second, but coordinates only updated every second
		function obj = interpolate_coordinates(obj)
			fdx = [1; find(obj.wgs84.lon(1:end-1) ~= obj.wgs84.lon(2:end) | obj.wgs84.lat(1:end-1) ~= obj.wgs84.lat(2:end))+1];
			if (fdx(end) ~= length(obj.time))
				fdx(end+1) = length(obj.time);
			end
			obj.interp.wgs84.lat = interp1(obj.time(fdx), obj.wgs84.lat(fdx), obj.time, 'linear');
			obj.interp.wgs84.lon = interp1(obj.time(fdx), obj.wgs84.lon(fdx), obj.time, 'linear');
			obj.interp.err = sqrt( (obj.interp.wgs84.lon - obj.wgs84.lon).^2 + (obj.interp.wgs84.lat - obj.wgs84.lat).^2 );
		end % interpCoords()

		% cobines altitude sampled with the dgps with depth soundings
		% to obtain the altitude of the river bottom
		function obj = calc_alt_bottom(obj, dgps, offset)
			% constants
			% TODO constants into the object header
			Ti_max = 1;
			if (~isa(dgps,'DGPS'))
				error('argument must be of class type DGPS');
			end
			% find samples of the dgps which correspond to samples of the dep by time
			obj.dgps.alt   = interp1(dgps.time, dgps.alt, obj.time,obj.ptype) + offset;
			obj.dgps.wgs84.lat   = interp1(dgps.time, dgps.wgs84.lat, obj.time, obj.ptype);
			obj.dgps.wgs84.lon   = interp1(dgps.time, dgps.wgs84.lon, obj.time,obj.ptype);
			% TODO compensate for vertical distance from gps receiver to water level
			obj.alt_bottom = -obj.depth + obj.dgps.alt;
			% obj.dgps.select = interp1(dgps.time, (1:length(dgps.time))', obj.time, 'nearest');
			% dt2 = (obj.time - dgps.time(obj.dgps.select) ).^2;
			dt2 = ( 86400*(obj.time - interp1(dgps.time, dgps.time, obj.time, 'nearest')) ).^2;
			% invalidate samples, where interpowgs84.lation is over wgs84.longer periods
			fdx = find( dt2 > Ti_max);
			obj.dgps.alt(fdx)   = NaN;
			obj.dgps.wgs84.lat(fdx)   = NaN;
			obj.dgps.wgs84.lon(fdx)   = NaN;
			obj.alt_bottom(fdx) = NaN;
			% error of positions of differential GPS and depth sounder GPS
			swgs84.lat = 40e6/360;
			swgs84.lon = 40e6/360*cos(deg2rad(obj.dgps.wgs84.lat));
			obj.dgps.err  = sqrt( swgs84.lon.^2.*(obj.dgps.wgs84.lon - obj.wgs84.lon).^2 + swgs84.lat^2*(obj.dgps.wgs84.lat - obj.wgs84.lat).^2);
			obj.dgps.ierr = sqrt( swgs84.lon.^2.*(obj.dgps.wgs84.lon - obj.interp.wgs84.lon).^2 + swgs84.lat*(obj.dgps.wgs84.lat - obj.interp.wgs84.lat).^2);
		end % calc_alt_bottom

		% remove points, which can be found by linear interpowgs84.lation with less than a minimum erorr
		% TODO melanobis distance, with more weight on depth
		function obj = sparsify(obj, d_max)

%			obj.sdx = 1:100:length(obj.time);
%			return;
%			if (isempty(obj.dgps.wgs84.lon))
%				error('dgps data required');
%			end

% TODO, there should be one type of sonar class with common export (merge sonar and DEP)
% TODO, interpowgs84.late the utm.X-coordinates
		fdx = find(0 ~= obj.utm.X);
		ds = 50;
		dis = cumsum([0; sqrt( diff(obj.utm.X(fdx)).^2 + diff(obj.utm.Y(fdx)).^2 ) ]);
		idx   = fix(dis(:)/ds)+1;
		N     = full(sparse(idx,ones(size(idx)),ones(size(idx))));
		s = obj.s;
		s.utm.X    = full(sparse(idx,ones(size(idx)),obj.utm.X(fdx)))./N;
		s.utm.Y    = full(sparse(idx,ones(size(idx)),obj.utm.Y(fdx)))./N;
		s.depth  = full(sparse(idx,ones(size(idx)),obj.depth(fdx)))./N;
		s.alt_bottom    = full(sparse(idx,ones(size(idx)),obj.alt_bottom(fdx)))./N;
		s.time = full(sparse(idx,ones(size(idx)),obj.time(fdx)))./N;
		% remove empty cells
		fdx = find(N > 0);
		s.utm.X = s.utm.X(fdx);
		s.utm.Y = s.utm.Y(fdx);
		s.depth = s.depth(fdx);
		s.alt_bottom = s.alt_bottom(fdx);
		s.time = s.time(fdx);
		obj.s = s;

%			m = 100;
%			n = fix(length(obj.time)/m);
% TODO, this is a problem when time jumps, or if the time step changes
 %			time       = reshape(obj.time(1:m*n)',n,m);
%			alt_bottom = reshape(obj.depth(1:m*n)',n,m);
%			depth      = reshape(obj.depth(1:m*n)',n,m);
%			utm.X          = reshape(obj.utm.X(1:m*n)',n,m);
%			utm.Y          = reshape(obj.utm.Y(1:m*n)',n,m);
%			obj.s.time       = mean(time,2);
%			obj.s.alt_bottom = median(alt_bottom,2);
%			obj.s.depth      = median(depth,2);
%			obj.s.utm.X          = median(utm.X,2);     
%			obj.s.utm.Y          = median(utm.Y,2);
		%
		%	this is too sophisticated and does not work reliably
		%
		%	% scale wgs84.lat and wgs84.lon approximately to metre
		%	swgs84.lat = 40e6/360;
		%	swgs84.lon = 40e6/360*cos(deg2rad(obj.dgps.wgs84.lat));
		%	A = [swgs84.lat*obj.dgps.wgs84.lat  swgs84.lon.*obj.dgps.wgs84.lon obj.alt_bottom];
		%	obj.sdx = (1:size(A,1));
		%	% remove nan values
		%	fdx = isnan(sum(A,2));
		%	while (~isempty(fdx))
		%		% remove interpowgs84.lateable rows
		%		A(fdx,:) = [];
		%		obj.sdx(fdx) = [];
		%		n = idivide(int32(size(A,1)),3);
		%		% interpowgs84.late even values
		%		I = 0.5*(A(1:2:n-2,:) + A(3:2:n,:));
		%		% get distance
		%		D = sum( (A(2:2:n-1,:) - I).^2,2 );
		%		% marks rows, which are less than the specific distance from its linear interpowgs84.lation away
		%		fdx = 2*find(D < d_max^2);
		%	end % while
	
		end % function sparify
		
		function obj = filter(obj)
			% constants
			% TODO into class definition
			thresh  = 0.5;
			rthresh = 2*thresh;
			d_max   = 49.5;
			niter   = 10;
			fdx = 1:length(obj.depth);
			% remove places where no depth is found
			fdx_ = obj.depth < d_max;
			fdx  = fdx(fdx_);
			for idx=1:niter
				d = diff(obj.depth(fdx));
				fdx_ = find(abs(d) < thresh);
				% remove samples where signal jumps
				fdx = fdx(fdx_);
				%depth(fdx+1) = depth(fdx);
			end % for idx
%			obj.filt.utm.X = obj.utm.X;
%		obj.filt.utm.Y = obj.utm.Y;
			obj.filt.depth = NaN(size(obj.depth));
			obj.filt.depth(fdx) = obj.depth(fdx);
			obj.filt.rdepth = obj.filt.depth;
			% now re-add points which where opportunistically deleted
			for idx=1:niter
				ddx = find(isnan(obj.filt.depth));
				obj.filt.rdepth(ddx) = interp1(obj.time(fdx),obj.depth(fdx),obj.time(ddx),'linear');
				d = abs(obj.filt.rdepth(ddx) - obj.depth(ddx));
				ddx_ = find(d > rthresh);
				fdx_ = find(d <= rthresh);
				obj.filt.rdepth(ddx(ddx_)) = NaN;
%			obj.filt.utm.X(ddx(ddx_)) = NaN;
%			obj.filt.utm.Y(ddx(ddx_)) = NaN;
				obj.filt.rdepth(ddx(fdx_)) = obj.depth(ddx(fdx_));
			end
			mdx = find(obj.filt.rdepth >  d_max);
			mdx_ = find(diff(mdx) > 10);
			fprintf('Valid samples removed due to depth limit\n');
			disp(datestr(obj.time([mdx(1); mdx(mdx_)]),'dd-mm-yy HH:MM:SS'));
		end % filter
		
		% Wed Jan  1 10:04:29 WIB 2014
		% Karl Kastner, Berlin
		function export_shp(obj, filename, fieldname, sflag)
%			if (isempty(obj.sdx))
%				error('sparsification required')
%			end
			s = struct('Geometry',[],'utm.X',[],'utm.Y',[]);
			% D.WGS84_wgs84.lat = -0.38212;
			% D.WGS84_wgs84.lon = 109.51927;
			%[utm.X utm.Y] = deg2utm(obj.interp.wgs84.lat(obj.sdx), obj.interp.wgs84.lon(obj.sdx));
			% correction for southern hemisphere
			n      = length(obj.s.time); %length(obj.sdx);
			utm.X      = obj.s.utm.X;
			utm.Y      = obj.s.utm.Y + 1e7;
			cg     = repmat({'Point'},n,1);
			cx     = num2cell(utm.X);
			cy     = num2cell(utm.Y);
			cfield               = num2cell(obj.s.(fieldname)); %(obj.sdx));
			[s(1:n).Geometry]    = deal(cg{:});
			[s(1:n).X]           = deal(cx{:});
			[s(1:n).Y]           = deal(cy{:});
			[s(1:n).(fieldname)] = deal(cfield{:});
			shapewrite(s, filename);
		end % export_shp
	end % methods
end % classdef DEP


