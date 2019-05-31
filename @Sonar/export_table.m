% Mon Mar 24 10:39:05 WIB 2014
% Karl Kastner, Berlin
%
% export the data into a text file
%
% This programme is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
%This programme is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this programme.  If not, see <https://www.gnu.org/licenses/>.
%
function obj = export_table(obj,ofilename)
		% output file
	if (nargin() < 2 || isempty(ofilename))
			fout = 1;
	else
		fout = fopen(ofilename,'w');
		if(-1 == fout)
			error('SLG::export_table');
		end
	end

	for pdx=1:length(obj.TimeOffset)
		fprintf(fout, ...
		... % 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27 
			    '%f,%f,%d,%f,%d,%f,%d,%f,%d,%f,%d,%f,%d,%d,%d,%d,%f,%d,%f,%d,%d,%d,%d,%f,%f,%d,%f\n', ...
				obj.UpperLimit(pdx), ...
				obj.LowerLimit(pdx), ...
				obj.DepthValid(pdx), ...
				obj.Depth(pdx), ...
				obj.WaterTempValid(pdx), ...
				obj.WaterTemp(pdx), ...
				obj.Temp2Valid(pdx), ...
				obj.Temp2(pdx), ...
				obj.Temp3Valid(pdx), ...
				obj.Temp3(pdx), ...
				obj.WaterSpeedValid(pdx), ...
				obj.WaterSpeed(pdx), ...
				obj.PositionValid(pdx), ...
				obj.PositionX(pdx), ...
				obj.PositionY(pdx), ...
				obj.SurfaceValid(pdx), ...
				obj.SurfaceDepth(pdx), ...
				obj.TopOfBottomValid(pdx), ...
				obj.TopOfBottomDepth(pdx), ...
				obj.ColumnIs50kHz(pdx), ...
				obj.TimeValid(pdx), ...
				obj.TimeOffset(pdx), ...
				obj.SpeedTrackValid(pdx), ...
				obj.Speed(pdx), ...
				obj.Track(pdx), ...
				obj.AltitudeValid(pdx), ...
				obj.Altitude(pdx));
			end % if fout
	end
	if (fout > 1)
		fclose(fout);
	end
end

