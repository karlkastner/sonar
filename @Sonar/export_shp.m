% 2014-04-10 22:27:01 +0700
% Karl Kastner, Berlin
%
% export the data into a shape file
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
%
% TODO actually the positions should be interpolated to the samples
% inbetween, and the poisition and depth should be averaged in each interval
% TODO correct time offset
%
function [shp obj] = export_shp(obj, ds)
	% TODO no magic numbers
	mode = 1;

	fdx = find(isfinite(obj.utm.X) & isfinite(obj.utm.Y) & isfinite(obj.Depth));
	if (length(fdx) < 2)
		shp = [];
		return;
	end

	% equidistant interpolation
	% TODO this suffers from severe round off due to the use of cumsum
	dS = hypot(diff(cvec(obj.utm.X(fdx))),diff(cvec(obj.utm.Y(fdx))));
	if (nargin() < 2)
		ds = median(dS);
	end
	dis = cumsum([0; dS]);

	if (0 == mode)
		% resample
		% TODO this is a quick fix to make the x-values monotonically decreasing
		dis = dis + 1e-7*dis(end)*linspace(0,1,length(dis))';
		Xi    = interp1(dis,obj.utm.X(fdx)',disi,'linear');
		Yi    = interp1(dis,obj.utm.Y(fdx)',disi,'linear');
		Di    = interp1(dis,obj.Depth(fdx)',disi,'linear');
		timei = interp1(dis,obj.time(fdx)',disi,'linear');
	else
		% average over the interval
		idx   = fix(dis(:)/ds)+1;
		N     = full(sparse(idx,ones(size(idx)),ones(size(idx))));
		iN    = 1./N;
		Xi    = iN.*full(sparse(idx,ones(size(idx)),obj.utm.X(fdx)));
		Yi    = iN.*full(sparse(idx,ones(size(idx)),obj.utm.Y(fdx)));
		Di    = iN.*full(sparse(idx,ones(size(idx)),double(obj.Depth(fdx))));
		timei = iN.*full(sparse(idx,ones(size(idx)),obj.time(fdx)));
	end
	fdx = find(~isnan(Di));
	shp = Shp.create('Geometry', 'Point', ...
			 'X',Xi(fdx), ...
			 'Y',Yi(fdx), ...
			 'time',timei(fdx), ...
			 'Depth',double(Di(fdx)));
end % export_shp

