% 2015-10-27 09:43:16.780458621 +0100
% Karl Kastner, Berlin
%
% export position of bed to xyz file
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
function obj = export_xyz(obj,filename)
	fid = fopen(filename,'w');
	if (-1 == fid)
		error(sprintf('Cannot open file %s for writing',filename));
	end
	fprintf(fid,'%f\t%f\t%f\n',[obj.utm.X, obj.utm.Y, -obj.Depth]');
	fclose(fid);
end % function export_xyz

