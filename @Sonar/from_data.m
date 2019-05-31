% Mon Mar 24 10:39:05 WIB 2014
% Karl Kastner, Berlin
%
% copy constructor
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
% TODO integrate this into the default constructor
function obj = from_data(obj, varargin)
	% values passed
	if (nargin() > 1)
		for idx=1:2:length(varargin)
			switch (varargin{idx})
			case {'X'}
				obj.utm.X = varargin{idx+1};
			case {'Y'}
				obj.utm.Y = varargin{idx+1};
			otherwise
				% TODO, check field existence and that idx+1 exists
				obj.(varargin{idx}) = varargin{idx+1};
			end % switch
		end % for
		obj.complete();
		return;
	end % if
end % from data

