% Fri 23 Sep 17:49:10 CEST 2016
% Karl Kastner, Berlin
%
% compate to slg files
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
%
function slg = compare(slg1,slg2)
	field_C = { ...
	      { 'DepthValid', 'Depth'} ...
	    , { 'WaterTempValid' , 'WaterTemp'} ...
	    , { 'Temp2Valid', 'Temp2' } ... 
	    , { 'Temp3Valid', 'Temp3' } ... 
	    , { 'WaterSpeedValid', 'WaterSpeed' } ... 
	    , { 'PositionValid', 'PositionX', 'PositionY' } ... 
	    , { 'SurfaceValid', 'SurfaceDepth' } ... 
	    , { 'TopOfBottomValid', 'TopOfBottomDepth' } ... 
	    , { 'SpeedTrackValid', 'Speed', 'Track' } ... 
	    , { 'AltitudeValid', 'Altitude' } ... 
	    , { 'TimeValid', 'TimeOffset' } ... 
	    , { 'ColumnIs50kHz' } ...
	    , { [], 'UpperLimit', 'LowerLimit'} ...
	    };

	for idx=1:length(field_C)
		group = field_C{idx};

		% compare values that are valid in any of the two sets
		field = group{1};
		if (~isempty(field))
			fdx = find((cvec(slg1.(field)) | cvec(slg2.(field))));
		else
			fdx = (1:length(slg1.Depth))'; %true(size(slg1.Depth));
		end % if
		if (any(fdx))
		for jdx=1:length(group)
			field = group{jdx};
			if (~isempty(field))
			d = double(cvec(slg1.(field)(fdx))) - double(cvec(slg2.(field)(fdx)));
			%dmax = norm(d,'inf');
			[dmax mdx] = max(abs(d));
			% TODO no magic numbers
			tol = 1e-5;
			if (dmax > tol)
				fprintf(1,'Field %s differs at index %d: %f\n',field,fdx(mdx),dmax);
			end
			mdx = find(isnan(d),1);
			if (~isempty(mdx))
				fprintf(1,'Field %s differs at index %d (NaN)\n',field,fdx(mdx));
			end
			end % if ~isempty
		end % for jdx
		end % if any
	end % for idx
end % compare

