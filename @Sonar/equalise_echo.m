% Mon Mar 24 22:49:43 WIB 2014
% Karl Kastner, Berlin
%
% Scale the echo intensity by bin size, as the echo sounder varies the bin size
% with the maximum depth.
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
% TODO, does the transmit pulse length change with changing depth limit ?
%
function obj = equalise_echo(obj)
%	obj.nbin = 200;
	obj.nbin = size(obj.ECHO,1);
%	range_max = max(obj.LowerLimit);
	range_max = quantile(obj.LowerLimit,0.9);
	scale = range_max ./ obj.LowerLimit;
		
	n1 = size(obj.ECHO,1);
	n2 = size(obj.ECHO,2);
%	ECHO = zeros(obj.nbin,n2);

	% row
	idx = round(n1/obj.nbin*(1:obj.nbin)'*scale(:)');
	fdx = find(idx > n1);
	idx(fdx) = n1;
	% col
	jdx = repmat(1:n2,obj.nbin,1);

%	ind = sub2ind([n1 n2], idx,jdx);
	ind = sub2ind_man([n1 n2], idx,jdx);
%	ind = int32(ind);
	obj.sECHO = obj.ECHO(ind);
	obj.sECHO(fdx) = 255;
	obj.R  = (1:obj.nbin)'*range_max/obj.nbin;
% TODO, make integer, or at least single
%	obj.bs = obj.sECHO + single(repmat(10*log10(obj.R.^2),1,n2));
	%obj.bs = obj.sECHO + uint8(repmat(10*log10(obj.R.^2),1,n2));
end % equalise_echo

