% Mon Mar 24 10:39:05 WIB 2014
% Karl Kastner, Berlin
%
% read data from slg-file
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
% TODO, there is a small bug, the header length is not computed correctly, see Chart 30_6_14 1657.slg sample 4000
function obj = from_slg(obj, ifilename, echoflag, t0, FileID, nmax)

	if (nargin() < 3 || isempty(echoflag))
		echoflag = false;
	end

	% start time
	% TODO, make t0 a member variable
	if (nargin() < 4 || isempty(t0))
		% try to scan t0 from file name
		base = basename(ifilename);
		%[val count] = sscanf(base,'%s-%d-%d-%d-%d-%d.slg');
		date_str = regexprep(base,'.*([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9]*-[0-9][0-9]-[0-9][0-9]).sl[g2]','$1');
		[val count] = sscanf(date_str,'%d-%d-%d-%d-%d');
		if (5 == count)
			% TODO bad quick fix
			if (val(1) > 31)
				% y m d
				t0 = datenum(val(1),val(2),val(3),val(4),val(5),0);
			else
				% d m y
				t0 = datenum(val(3),val(2),val(1),val(4),val(5),0);
			end
		else
			t0 = 0;
			warning('No start time given, start time could not be parsed from file name');
		end
	end

	if (nargin() < 5 || isempty(FileID))
		FileID = 1;
	end

	if (nargin() < 6 || isempty(nmax))
		nmax = inf;
	end

	% read input file
	stream = Stream();
	stream.init(ifilename);



	% read header
	obj.headerlen = 10;
	obj.header    = stream.read_uint8(obj.headerlen);
	if (stream.pos < obj.headerlen)
		return;
	end % if

	% determine number of bytes per block
	obj.blocklen = 256*double(obj.header(6)) + double(obj.header(5));

	% read data for each ping individually
	pdx = 1;
	try
	while (1)
		pos0 = stream.pos;
		% get the quality indicator bitmask
		obj.quality(pdx) =      double(stream.read_uint8())      ...
				   +256*double(stream.read_uint8());
		% analyse the quality indicator
		% note : location in header does not correspond with location in bitmask,
		% nor do they correspond with order in the slg2txt table
 		% unexplained bits: 0 1 2 3 _ 5 6 _ _ 9 _ 11 12  _ _ _
		%DepthV		11
		obj.DepthValid(pdx)        = bitand(obj.quality(pdx),2^11) > 0;
		%WTempV		4
		obj.WaterTempValid(pdx)    = bitand(obj.quality(pdx),2^4) > 0;
		%Temp2V ?
		obj.Temp2Valid(pdx) = 0;
		obj.Temp2(pdx) = obj.myNaN;
		%Temp3V	?
		obj.Temp3Valid(pdx) = 0;
		obj.Temp3(pdx) = obj.myNaN;
		%WSpdV		7
		obj.WaterSpeedValid(pdx)    = bitand(obj.quality(pdx),2^7) > 0;
		%PosV		2
		obj.PositionValid(pdx)      = bitand(obj.quality(pdx),2^2) > 0;
		%SurfaceDepth	10
		obj.SurfaceValid(pdx)       = bitand(obj.quality(pdx),2^10) > 0;
		%TopOfBottomDepth	10
		obj.TopOfBottomValid(pdx)   = bitand(obj.quality(pdx),2^10) > 0;
		%ColumnIs50kHz	15
		obj.ColumnIs50kHz(pdx)      = bitand(obj.quality(pdx),2^15) > 0;
		%TimeV		13
		obj.TimeValid(pdx)          = bitand(obj.quality(pdx),2^13) > 0;
		%SpdTrackV	8
		obj.SpeedTrackValid(pdx)    = bitand(obj.quality(pdx),2^8) > 0;
		%AltV		14
		obj.AltitudeValid(pdx)      = bitand(obj.quality(pdx),2^14) > 0;


		% TODO where is the UpperLimit stored ?
		obj.UpperLimit(pdx) = single(0.0);

		% read the lower limit
		% TODO (always valid or is there a quality flag?)
		obj.LowerLimit(pdx)  = stream.read_float();
				% read depth
 		% DepthV 1   - 5  ( 6 )
		%if (obj.DepthValid(pdx))
		% depth seems to be always stored, irrespecively, if the value is valid or not
			obj.Depth(pdx) = stream.read_float();
					%else
		%	obj.Depth(pdx) = obj.myNaN;
		%end

		% read water temperature
		if (obj.WaterTempValid(pdx))
			obj.WaterTemp(pdx) = stream.read_float();
		else
			obj.WaterTemp(pdx) = obj.myNaN;
		end

		% read WaterSpeed
		if (obj.WaterSpeedValid(pdx))
			obj.WaterSpeed(pdx) = stream.read_float();
		else
			obj.WaterSpeed(pdx) = NaN;
		end
	
		% read position
		if (obj.PositionValid(pdx))
			% y comes first
			obj.PositionY(pdx) = stream.read_int32();
			obj.PositionX(pdx) = stream.read_int32();
		else
			obj.PositionX(pdx) = obj.myNaN;
			obj.PositionY(pdx) = obj.myNaN;
		end

		% read surface Depth
		if (obj.SurfaceValid(pdx))
			obj.SurfaceDepth(pdx) = stream.read_float();
		else
			obj.SurfaceDepth(pdx) = obj.myNaN;
		end

		% read TopOfBottomDepth (5) or 6
		if (obj.TopOfBottomValid(pdx))
			obj.TopOfBottomDepth(pdx) = stream.read_float();
		else
			obj.TopOfBottomDepth(pdx) = obj.myNaN;
		end

		if (bitand(obj.quality(pdx),1)>0)
			obj.unknown1(pdx) = stream.read_float();
		else
			obj.unknown1(pdx) = NaN;
		end

		% read time offset
		if (obj.TimeValid(pdx))
			obj.TimeOffset(pdx) = stream.read_uint32();
		else
			obj.TimeOffset(pdx) = obj.myNaN;
			% TODO, this is a quick fix for postprocessing, no time, no position
			obj.PositionY(pdx) = obj.myNaN;
		end


		% read speed of track (2) 8 (14)
		if (obj.SpeedTrackValid(pdx))
			obj.Speed(pdx) = stream.read_float();
			obj.Track(pdx) = stream.read_float();
		else
			obj.Speed(pdx) = obj.myNaN;
			obj.Track(pdx) = obj.myNaN;
		end

		% read altitude (2) (8) 14
		if (obj.AltitudeValid(pdx))
			obj.Altitude(pdx) = stream.read_float();
		else
			obj.Altitude(pdx) = obj.myNaN;
		end

		for idx=1:20
%			obj.single(pdx,idx)= stream.read_float();
%			obj.int32(pdx,idx)=typecast(next((3+4*(idx-1)):(3+4*idx)-1),'int32');
		end

		% check that first echo is max (128), other values indicate incomplete parsing of header
		if (stream.data(stream.pos+1) ~= 128)
			fprintf(1,'Warning: First backscatter bin is not 128 for in %d in file %s\n',pdx,ifilename);
		end

		% tail is echo intensity
		obj.l(pdx) = pos0+obj.blocklen-stream.pos;

		if (echoflag)
			obj.ECHO(1:min(length(next),obj.blocklen)-pos+1,pdx) = obj.read_uint8(l);
			%next(pos:end);
		else
			stream.skip(obj.l(pdx));
		end
		% next ping
		pdx = pdx+1;
		if (pdx > nmax)
			break;
		end
	end % while(1)
	catch
	end	
	obj.to_metric(t0);

%	% somehow the depthValid information is sometimes bogus
%	% the depth can be assumed invalid, if it does not change
%	fdx = find(diff(obj.Depth) == 0)+1;
%	% invalidate samples where the depth did not change
%	obj.Depth(fdx) = NaN;

	% somehow the depthValid information is sometimes bogus
	% the depth can be assumed invalid, if it does not change
	obj.orig.Depth = obj.Depth;
	obj.DepthHold  = [false; cvec(diff(obj.Depth) == 0)];
	obj.DepthValid = cvec(obj.DepthValid) & ~obj.DepthHold;
	% invalidate samples where the depth did not change
	obj.Depth(obj.DepthHold) = NaN;

	% interpolate the position values
	fdx = find(obj.PositionValid);
	% TODO, limit interpolation to time / distance
	if (length(fdx) > 1)
		try 
			obj.PositionX = interp1(double(obj.TimeOffset(fdx)),double(obj.PositionX(fdx)),double(obj.TimeOffset),obj.imethod);
			obj.PositionY = interp1(double(obj.TimeOffset(fdx)),double(obj.PositionY(fdx)),double(obj.TimeOffset),obj.imethod);
		catch
			warning('here');
		end
	end

	% convert coordinates to UTM
	[obj.wgs84.lat obj.wgs84.lon] = lowrance_mercator_to_wgs84(double(obj.PositionX),double(obj.PositionY));
	[obj.utm.X obj.utm.Y] = latlon2utm(obj.wgs84.lat, obj.wgs84.lon, obj.zone);
	
	obj.FileID = FileID*ones(size(obj.Depth));
	
	% at last the echo intensity has to be "stretched" according to the binsize
	obj.complete();

end % from_slg()

