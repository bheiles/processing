function lolliplot(x,y,varargin)
% Custom function for lolliplots

% Dirty coloring
if nargin>2
    FaceColors=varargin{1};
    EdgeColors=varargin{2};
    % Plot per column
    for idx=1:size(FaceColors,2)
        h=stem(x(:,idx),y(:,idx),'filled','MarkerFaceColor',FaceColors(:,idx),'MarkerEdgeColor',EdgeColors(:,idx),...
            'MarkerSize',15,'LineWidth',1);hold on
        h.Color=EdgeColors(:,idx);
    end
else
        stem(x,y,'filled','MarkerSize',15,'LineWidth',1);
end

f=gcf;
for element = 1:numel(y)
    val = sprintf('%3.0f',y(element));
    if sign(y(element)) == 1
        text(x(element)-0.1,y(element),val,'Color','k');
    else
        text(x(element)-0.1,y(element),val,'Color','k');
    end
end
grid on;
ax=gca;ax.Box='off';
f.InvertHardcopy='off';f.Color='w';
end