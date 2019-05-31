% Fri Nov 22 17:48:01 UTC 2013
% Karl Kästner, Berlin
%
% sort files by start time
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
function filename = sortfiles(obj,filename)
	t = zeros(size(filename));
	for idx=1:length(filename)
		fid = fopen(filename{idx},'r');
		if (-1 == fid)
			t(idx) = Inf;
			continue;
		end
		% read first line
		s = fgetl(fid);
		fclose(fid);
		% stop at end of file
		if (-1 == s)
			t(idx) = Inf;
			continue;
		end % if
		% tokenise
                token = strsplit(s,',');
		% time
		t(idx) = datenum([token{1} ' ' token{2} '0'], 'mm-dd-yy HH:MM:SS.FFF');
	end % for idx
	[t, sdx] = sort(t);
	filename = filename(sdx);
end % sortfiles

