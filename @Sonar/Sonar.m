% Mon Mar 24 10:39:05 WIB 2014
% Karl Kastner, Berlin
%
% Class to read in Lowrance echo sounder data
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
classdef Sonar < handle
	properties
		header
		headerlen
		blocklen
		quality
		l
		ECHO
		sECHO
		bs
		R
		nbin
		time
		format
		version
		% These are unknown data fields
		unknown0
		unknown1
		unknown2
		unknown3
		unknown4
		unknown5
		unknown6
		unknown7
		unknown8
		unknown9
		unknown10
		unknown11
		unknown12
		unknown13
		unknown14
		unknown15
		unknown16
		unknown17
		unknown18
		unknown19
		packetsize
		offset
		frameindex
		blockflag = false;
		block;
		wgs84 = struct('lat',[],'lon',[]);
		utm   = struct('X',[],'Y',[]);
		% Lowrance features
		blocksize  = [];
		last_blocksize  = [];
		last_offset  = [];
		UpperLimit = zeros(0,0,'single');
		LowerLimit = zeros(0,0,'single');
		DepthValid = false(0,0);
		DepthHold  = false(0,0);
		% WaterDepth in SL2
		Depth	   = zeros(0,0,'single');
		KeelDepth  = zeros(0,0,'single');
		Heading    = [];
		WaterTempValid = false(0,0);
		%WaterTemperature  = zeros(0,0,'single');
		WaterTemp       = zeros(0,0,'single');
		Temp2Valid      = false(0,0);
		Temp2		= zeros(0,0,'single');
		Temp3Valid      = false(0,0);
		Temp3		= zeros(0,0,'single');
		WaterSpeedValid = false(0,0);
		WaterSpeed	= zeros(0,0,'single');
		PositionValid	= false(0,0);
		%Easting = [];, %Northing = [];
		PositionX	= zeros(0,0,'int32');
		PositionY	= zeros(0,0,'int32');
		SurfaceValid	= false(0,0);
		SurfaceDepth		= zeros(0,0,'single');
		TopOfBottomValid	= false(0,0);
		TopOfBottomDepth	= zeros(0,0,'single');
		ColumnIs50kHz		= false(0,0);
		TimeValid		= false(0,0);
		TimeOffset		= zeros(0,0,'int32');
		SpeedTrackValid		= false(0,0);
		Speed			= zeros(0,0,'single');
		Track			= zeros(0,0,'single');
		TrackValid              = false(0,0);
		SpeedValid              = false(0,0);
		HeadingValid              = false(0,0);
		AltitudeValid		= false(0,0);
		Altitude		= zeros(0,0,'single');
		Channel = [];
		Frequency = [];
		time1 = [];
		%
		% DEP features
		%
		% altitude of the bottom (computed from shipboarn altitude DGPS)
		alt_bottom;
		alt_surface;
		% altitude of bottom inferred from surface altitude at closest
		% gauging stations
		alt_bottom_extrapolated;
		
		% standard deviation of depth, if points were averaged
		sDepth = zeros(0,0,'single');
		% number of points, if averageed
		nsample = zeros(0,0,'int32');
		% index of reference gauge
		reference_gauge;

		FileID;
		%int32
		%single
		orig

		% TODO make this a separate struct?
		datafield_C = { ...
			  'Channel' ...
			, 'frameindex' ...
			, 'quality' ...
			, 'UpperLimit' ...
			, 'LowerLimit' ...
			, 'time1' ...
			, 'DepthValid' ...
			, 'Depth' ...
			, 'Heading' ...
			, 'Speed' ...
			, 'KeelDepth' ...
			, 'WaterTempValid' ...
			, 'WaterTemp' ...
			, 'Temp2Valid' ...
			, 'Temp2' ...
			, 'Temp3Valid' ...
			, 'Temp3' ...
			, 'WaterSpeedValid' ...
			, 'WaterSpeed' ...
			, 'PositionValid' ...
			, 'PositionX' ...
			, 'PositionY' ...
			, 'SurfaceValid' ...
		        , 'SurfaceDepth' ...
			, 'TopOfBottomValid' ...
			, 'TopOfBottomDepth' ...
			, 'ColumnIs50kHz' ...
			, 'TimeValid' ...
			, 'TimeOffset' ...
			, 'SpeedTrackValid' ...
			, 'Speed' ...
			, 'Track' ...
			, 'AltitudeValid' ...
			, 'Altitude' ...
			, 'FileID' ...
			};
	end % properties

	properties (Constant)
		% constants
		metre_per_feet            = 0.3048;
		metre_per_second_per_knot = 0.514444444;
		days_per_millisec         = (1e-3/86400);
		% invalid values are replace by zero by the vendor software
		% qgis crashes with NULL / NaN values, so we use zero here too
		myNaN   = 0;
		zone    = '49M'
		imethod = 'linear';
	end % properties (const)

	methods (Access = private)
		obj = from_dep(obj,dep);
	end % private methods

	methods
	%
	% prototypes for function in external files
	%
		obj = cat(obj,obj2);
		obj = equalise_echo(obj);
		[shp obj] = export_shp(obj, ds);

	% pseudo variables
	function [n, obj] = nens(obj)
		n = length(obj.time);
	end % nens

	% default constructor
	function obj = Sonar(ifilename)
		% default constructor for empty object
		if (nargin() < 1)
			return;
		end

		% parse input arguments
		if (isa(ifilename,'DEP'))
			obj.from_dep(ifilename);
			return;
		end
	end % constructor

	% Fri Jun 27 11:53:45 WIB 2014
	% Karl Kastner, Berlin
	% quick filter
	function obj=filter(obj)
		% remove nan values
		% TODO, this is a bit tricky, if it was an adcp structure, then WGS84 can be zero-invalid
		% but if it was a lowrance device, than PositionX and Y are zero-invalid
		fdx = find(~isfinite(obj.utm.X.*obj.utm.Y.*obj.Depth) ...
			    | (obj.wgs84.lat == 0 | obj.wgs84.lon == 0));
		% TODO improve filter for GPS outliers ->
		% position cannot be right, if it suddenly jumps (high velocity)
		obj.remove(fdx);
		% filter outliers, v > 72km/h
		fdx = find(sqrt(diff(obj.utm.X).^2 + diff(obj.utm.Y).^2)./abs(24*3600*diff(obj.time)) > 20);
		obj.remove(fdx);
	end

	end % methods
end % classdef Sonar

