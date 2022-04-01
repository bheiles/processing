function cleanFigure(f,varargin)
%% Function to have publication friendly figures
% Created by Baptiste Heiles on 2022/03/30
% Last modified by Baptiste Heiles on 2022/03/30
% cleanFigure(f) applies default layout to figure f
% cleanFigure(f,'black') applies black background default layout to figure
% f

if nargin>2
    mode=varargin{1};
else
    mode='white';
end

switch mode
    case 'white'
        f.Color='w';
        f.InvertHardcopy='off';
    case 'black'
        f.Color='k';
        f.InvertHardcopy='off';
end


ax=gca(f);
ax.Box='off';
axis image;
f.InvertHardcopy='off';f.Color='w';colorbar;
grid on;
l=legend;l.Box='off';
title('Title');
xlabel('xlabel');
ylabel('ylabel','Rotation',0,'Position',[8.8454   11.8864   -1.0000]);

