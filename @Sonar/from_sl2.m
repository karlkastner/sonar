% Wed 19 Oct 13:28:11 CEST 2016
% Karl Kastner, Berlin
%
% read sl2 into slg-like object
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
function obj = from_sl2(obj, ifilename, echoflag, t0, FileID, nmax)

	if (nargin() < 3 || isempty(echoflag))
		echoflag = false;
	end
	
	% start time
	% TODO, make t0 a member variable
	if (nargin() < 4 || isempty(t0))
		% try to scan t0 from file name
		base = basename(ifilename);
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
	header     = stream.read_uint8(obj.headerlen);
	stream.pos = stream.pos-obj.headerlen;

	% 0 : slg, 1 : sl2
	obj.format = stream.read_int16();
	% 2 (or device)
	obj.version = stream.read_int16();
	% 4
	obj.unknown0 = stream.read_uint8(6);
	
	%stream.skip(obj.headerlen);
	if (stream.pos < obj.headerlen)
		return;
	end

	if (1)
	    % two stage blockwise reading
	    % this is considerably faster than reading individual values
	    idx  = 0;
	    pos0 = stream.pos;

	    stream.skip(26);
	    % stage 1: parse blocksize
	    while (~stream.end())
	    	idx=idx+1;
	    	obj.blocksize(idx,1) = stream.read_int16();
	    	if (obj.blocksize(idx) <= 0)
	    		error('Non positive block size');
	    	end
	    	stream.skip(obj.blocksize(idx)-2);
	    	if (idx>nmax)
	    		break;
	    	end
	    end % while ~stream.end

	    % discard last incomplete block
	    obj.blocksize = obj.blocksize(1:end-1);

	    % stage 2: get block data
	    block = zeros(length(obj.blocksize),max(obj.blocksize),'uint8');
	    stream.pos = pos0;
	    for idx=1:length(obj.blocksize)
	    	block(idx,:) = stream.read(obj.blocksize(idx));
	    end

	    % extract the fields
	    % 0
	    %obj.offset       =   stream.read_int16() ...
	    %		         + 65536*stream.read_int16();
	    % 4
	    %obj.last_offset  =   stream.read_int16() ...
            %                        + 65536*stream.read_int16();
	    obj.unknown1      = block(:,  8+(1:2));	% 0
	    % 10
	    %obj.last_offset2 = stream.read_int16() ...
	    %			 + 65536*stream.read_int16();
	    obj.unknown2      = block(:, 14+(1:2));	% 0
	    obj.unknown3      = block(:, 16+(1:2));	% 0
	    obj.unknown4      = block(:, 18+(1:2));	% 0
	    obj.unknown5      = block(:, 20+(1:2));	% 0
	    obj.unknown6      = block(:, 22+(1:2));	% 0
	    obj.unknown7      = block(:, 24+(1:2));	% 0
	    obj.blocksize     = block(:, 26+(1:2));
	    obj.last_blocksize= block(:, 28+(1:2));
	    obj.Channel       = block(:, 30+(1:2));
	    obj.packetsize    = block(:, 32+(1:2));
	    obj.frameindex    = block(:, 34+(1:4));
	    obj.UpperLimit    = block(:, 38+(1:4));
	    obj.LowerLimit    = block(:, 42+(1:4));
	    obj.unknown8      = block(:, 46+(1:4));	% meas data
	    obj.unknown9      = block(:, 50+1);
	    % 51
	    % stream.skip(4));
	    obj.Frequency     = block(:, 55+1);
	    obj.unknown10     = block(:, 56+(1:2));
	    obj.time1         = block(:, 58+(1:4));
	    obj.Depth         = block(:, 62+(1:4));
	    obj.unknown11     = block(:, 66+(1:4));	% flags ?
	    obj.unknown12     = block(:, 70+(1:4));	% meas data ?
	    obj.KeelDepth     = block(:, 74+(1:4)); 
	    obj.unknown13     = block(:, 78+(1:4));	% flags ? 
	    obj.unknown14     = block(:, 82+(1:4)); 	% flags ?
	    obj.unknown15     = block(:, 86+(1:4)); 	% flags ?
	    obj.unknown16     = block(:, 90+(1:4)); 	% flags ?
	    obj.unknown17     = block(:, 94+(1:4)); 	% flags ?
	    obj.Speed         = block(:, 98+(1:4)); 
	    obj.WaterTemp     = block(:,102+(1:4)); 
	    obj.PositionX     = block(:,106+(1:4));
	    obj.PositionY     = block(:,110+(1:4)); 
	    obj.WaterSpeed    = block(:,114+(1:4)); 
	    obj.Track         = block(:,118+(1:4)); 
	    obj.Altitude      = block(:,122+(1:4)); 
	    obj.Heading       = block(:,126+(1:4)); 
	    obj.quality       = block(:,130+(1:2)); 
	    obj.unknown18     = block(:,132+(1:2)); 	% 0
	    obj.unknown19     = block(:,134+(1:4)); 	% flags
	    obj.TimeOffset    = block(:,138+(1:4)); 
	else % of if 1
		obj = read_individually(obj);
	end

	% type casts
	obj.Channel     = typecast(flat(obj.Channel'),'int16');
	obj.frameindex  = typecast(flat(obj.frameindex'),'uint32');
	obj.UpperLimit  = typecast(flat(obj.UpperLimit'),'single');
	obj.LowerLimit  = typecast(flat(obj.LowerLimit'),'single');
	obj.time1       = typecast(flat(obj.time1'),'uint32');
	obj.Depth       = typecast(flat(obj.Depth'),'single');	
	obj.KeelDepth   = typecast(flat(obj.KeelDepth'),'single');
	obj.Speed       = typecast(flat(obj.Speed'),'single');
	obj.WaterTemp   = typecast(flat(obj.WaterTemp'),'single');
	obj.PositionX   = typecast(flat(obj.PositionX'),'int32');
	obj.PositionY   = typecast(flat(obj.PositionY'),'int32');
	obj.WaterSpeed  = typecast(flat(obj.WaterSpeed'),'single');
	obj.Track       = typecast(flat(obj.Track'),'single');
	obj.Altitude    = typecast(flat(obj.Altitude'),'single');
	obj.Heading     = typecast(flat(obj.Heading'),'single');	
	obj.quality     = typecast(flat(obj.quality'),'uint16');
	obj.TimeOffset  = typecast(flat(obj.TimeOffset'),'uint32');

	% resolve channel
		% 0 = Primary (Traditional Sonar)
	    	% 1 = Secondary (Traditional Sonar)
	    	% 2 = DSI (Downscan Imaging)
	    	% 3 = Sidescan Left
	    	% 4 = Sidescan Right
	    	% 5 = Sidescan (Composite)

	% resolve bitmask
		obj.TrackValid      = bitand(obj.quality,1) > 0;
		obj.WaterSpeedValid = bitand(obj.quality,2.^1) > 0;
		%     2 = Unknown
		%obj.PositionValid   = bitand(obj.quality,2.^3) > 0;
		obj.DepthValid       = bitand(obj.quality,2.^3) > 0;
		%     4 = Unknown
		obj.WaterTempValid  = bitand(obj.quality,2.^5) > 0;
		obj.SpeedValid      = bitand(obj.quality,2.^6) > 0;
		%     7 to 13 = Unknown
		obj.AltitudeValid   = bitand(obj.quality,2.^14) > 0;
		obj.HeadingValid    = bitand(obj.quality,2.^15) > 0;
	% resolve frequency
	    	% 0 = 200KHz
	    	% 1 = 50KHz
	    	% 2 = 83KHz
	    	% 3 = 455KHz
	    	% 4 = 800KHz
	    	% 5 = 38KHz
	    	% 6 = 28KHz
	    	% 7 = 130KHz - 210KHz
	    	% 8 = 90KHz - 150KHz
	    	% 9 = 40KHz - 60KHz
	    	% 10 = 25KHz - 45KHz
	    	% Any other value is treated as 200KHz

	% convert units from units to SI
	obj.to_metric(t0);

	% invalidate Depth
	% TODO not just depth
	obj.orig.Depth = obj.Depth;
	fdx = (obj.DepthValid);
	obj.Depth(~fdx) = NaN;

if (0)
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
end
	% convert coordinates to UTM
	[obj.wgs84.lat obj.wgs84.lon] = lowrance_mercator_to_wgs84(double(obj.PositionX),double(obj.PositionY));
	[obj.utm.X obj.utm.Y] = latlon2utm(obj.wgs84.lat, obj.wgs84.lon, obj.zone);

	obj.FileID = FileID*ones(size(obj.Depth));
	
	% stretch echo intensity according to the binsize
	obj.complete();
end % from_sl2

function obj = read_individually(obj)
	% read data for each ping individually
	idx = 0;
	try
	while (1) %~stream.eof())
		idx=idx+1;
%		[stream.data(10+(1:100)),stream.data(stream.pos+(1:100))]

		posi = stream.pos;
		% 0
		obj.offset(idx)        =   stream.read_int16() ...
				         + 65536*stream.read_int16();
		% 4
		last_offset(idx)       =   stream.read_int16() ...
	                                 + 65536*stream.read_int16();
		% 8 (int16)
		unknown1(idx,:)        = stream.read(2);
		% 10
		last_offset2(idx)      = stream.read_int16() ...
					 + 65536*stream.read_int16();
		% 14 int16
		obj.unknown2(idx,:)    = stream.read(2);
		% 16 int16
		obj.unknown3(idx,:)    = stream.read(2);
		% 18 int16
		obj.unknown4(idx,:)    = stream.read(2);
		% 20 int16
		obj.unknown5(idx,:)    = stream.read(2);
		% 22 int16
		obj.unknown6(idx,:)    = stream.read(2);
		% 24 int16
		obj.unknown7(idx,:)    = stream.read(2);
		% 26
		obj.blocksize(idx)     = stream.read_int16();
		% copy entire block (for debugging)
		if (obj.blockflag)
			pos = stream.pos;
			stream.pos = posi;
			obj.block(idx,1:obj.blocksize(idx)) = stream.read_uint8(obj.blocksize);
			stream.pos = pos;
		end
		% 28 
		last_blockSize(idx)    = stream.read_int16();
		% 30 (int16)
		obj.Channel(idx,:)     = stream.read(2);
		% 32 
		obj.packetsize(idx,:)  = stream.read_int16();
		% 34 (uint32)
		obj.frameindex(idx,:)  = stream.read(4);
		% 38 (float)
		obj.UpperLimit(idx,:)  = stream.read(4);
		% 42 (float)
		obj.LowerLimit(idx,:)  = stream.read(4);
		% 46 (uint32)
		unknown8(idx,:)	          = stream.read(4);
		% 50
		unknown9(idx,:)	          = stream.read_uint8();
		% 51
		stream.skip(4);
		% 55
		obj.Frequency(idx,:)      = stream.read_uint8();
		% 56 (int16)
		obj.unknown10(idx,:)      = stream.read(2);
		% 58 (uint32)
		obj.time1(idx,:)          = stream.read(4);
		% 62 (float)
		obj.Depth(idx,:)          = stream.read(4);
		% 66 (unit32)
		obj.unknown11(idx,:)      = stream.read(4);
		% 70 (uin32)
		obj.unknown12(idx,:)      = stream.read(4);
		% 74 (float)
		obj.KeelDepth(idx,:)      = stream.read(4); 
		% 78 (float)
		obj.unknown13(idx,:)      = stream.read(4); 
		% 82 (float)
		obj.unknown14(idx,:)      = stream.read(4); 
		% 86 (float)
		obj.unknown15(idx,:)      = stream.read(4); 
		% 90 (float)
		obj.unknown16(idx,:)      = stream.read(4); 
		% 94 (float)
		obj.unknown17(idx,:)      = stream.read(4); 
		% 98 (float)
		obj.Speed(idx,:)          = stream.read(4); 
		% 102 (float)
		obj.WaterTemp(idx,:)      = stream.read(4); 
		% 106
		obj.PositionX(idx,:)      = stream.read(4); % read_int32();
		% 110 (int32)
		obj.PositionY(idx,:)      = stream.read(4); 
		% 114 (float)
		obj.WaterSpeed(idx,:)     = stream.read(4); 
		% 118 (float)
		obj.Track(idx,:)	  = stream.read(4); 
		% 122 (float)
		obj.Altitude(idx,:)       = stream.read(4); 
		% 126 (float)
		obj.Heading(idx,:)        = stream.read(4); 
		% 130
		obj.quality(idx,:)        = stream.read(2); 
		% 132 (int16)
		obj.unknown18(idx,:)      = stream.read(2); 
		% 134 (uint32)
		obj.unknown19(idx,:)      = stream.read(4); 
		% 138
		obj.TimeOffset(idx,:)     = stream.read(4); 
		% 142
		stream.skip(2);
		% 144
		% TODO read backscatter data
		stream.skip(obj.packetsize(idx));

		if (stream.pos ~= posi + obj.blocksize(idx))
			fprintf('Warning: Block size does not match %d %d\n',stream.pos-pos0,obj.blocksize(idx));
		end 
		if (idx >= nmax)
			break;
		end
	end % while 1
%	end
	catch e
		disp(e);
	end
end % function read_individually

