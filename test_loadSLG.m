% 2014-03-24 14:41:49.342022030 +0100
% Karl Kastner, Berlin

%slg = loadSLG('Chart_17_1_12[6].slg');
%load out.csv
%slg = loadSLG([ROOTFOLDER, '/dat/kapuas/2014-03-17-bathymetry-kubu/chart-17_3_14-1.slg']);
%
%n=size(slg.pingheader,1);
%for idx=1:n;
%subplot(ceil(n/4),4,idx);
%plot(slg.pingheader(idx,:));
%ylim([0 255]);
%title(idx); end

% select only maximum length samples
fdx=find(slg.index == 27924);
nrange = fdx; %1:100; %73200:73300;
figure(1);
subplot(2,1,1)
imagesc(nrange,1:size(slg.ECHO,1),slg.ECHO(:,nrange))
subplot(2,1,2)
plot(nrange,sum(slg.pingheader(1:2,nrange))')
%imagesc(slg.ECHO(:,1:nmax))

figure(2)
cols = 6;
n=size(slg.pingheader,1);
rows = ceil(n/cols);
	for idx=1:n;
		%subplot(ceil(n/cols),cols,idx);
		%set(gca, 'LooseInset', get(gca,'TightInset'))
	        %subaxis(ceil(n/cols),cols, idx, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
	        [c,r] = ind2sub([cols rows], idx);
		subplot('Position', [(c-1)/cols, 1-(r)/rows, 1/cols, 1/rows])
		plot(nrange,slg.pingheader(idx,nrange),'.-');
		ylim([0 255]);
		title(idx);
	end
%subplot(8,4,32);
%plot(nrange,slg.ECHO(1,nrange))
%ylim([0 255]);

%figure(3); plot([slg.depth' slg.dmax'])
%figure(4); plot(slg.time)
%        1         2,      3,     4,      5,     6,      7,    8,     9,  10,    11,  12,  13   14,  15,          16,      17,              18,          19,           20,   21,        22,       23, 24,   25,  26, 27
% UpperLim, LowerLim, DepthV, Depth, WTempV, WTemp, Temp2V,Temp2,Temp3V,Temp3,WSpdV,WSpd,PosV,PosX,PosY,SurfaceDepth,SurfaceV,TopOfBottomDepth,TopOfBottomV,ColumnIs50kHz,TimeV,TimeOffset,SpdTrackV,Spd,Track,AltV,Alt
leg = {'UpperLim', ' LowerLim', 'DepthV', 'Depth', 'WTempV', ' WTemp', ' Temp2V', 'Temp2', 'Temp3V', 'Temp3', 'WSpdV', 'WSpd', 'PosV', 'PosX', 'PosY', 'SurfaceDepth', 'SurfaceV', 'TopOfBottomDepth', 'TopOfBottomV', 'ColumnIs50kHz', 'TimeV', 'TimeOffset', 'SpdTrackV', 'Spd', 'Track', 'AltV', 'Alt'};
%                                                                                                                 16-17         18-19
%cols = [3 5 7 9 11 13 17 19 20 21 23 26];
cols = [3 5 7 9 11 13 16 18 20  21 23 26];
max(out(:,cols))
C = out(:,cols);
D = dec2bin(slg.index',16) == '1';
D = fliplr(D);
for idx=1:size(C,2)
	%for jdx=1:16
	Ci = repmat(C(:,idx),1,16);
	disp([leg{cols(idx)} ' ' num2str(max(C(:,idx))) ' - ' num2str(find(max(abs((D - Ci)))==0)) ])
	%end
end

