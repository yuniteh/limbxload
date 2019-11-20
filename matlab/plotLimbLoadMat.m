function plotLimbLoadMat(varargin)
% number of arguments
switch (nargin)
    case 5
       mat = varargin{1};
       truemat = varargin{2};
       xlab = varargin{3};
       ylab = varargin{4};
       colors = varargin{5};
end

mat(isnan(mat))=0; % in case there are NaN elements
numX = size(xlab, 2); % number of labels
numY = size(ylab, 2);

% calculate the percentage accuracies
matperc = 100*mat./truemat;
matstd = std(reshape(matperc,1,[]));

% plotting the colors
imagesc(matperc,[50 100]);
title(['Accuracy: ' num2str(mean(reshape(matperc,1,[])),'%.2f') ' \pm ' num2str(matstd,'%.2f') '%'])
%title(sprintf('Accuracy: %.2f% \pm %.2f%%', mean(reshape(matperc,1,[])), matstd));
xlabel('Limb Position'); ylabel('Load (g)');

% set the colormap
colormap(linspecer(colors));

% Create strings from the matrix values and remove spaces
textStrings = num2str(matperc(:), '%.1f%%');
textStrings = strtrim(cellstr(textStrings));

% Create x and y coordinates for the strings and plot them
[x,y] = meshgrid(1:numX,1:numY);
hStrings = text(x(:),y(:),textStrings(:), ...
    'HorizontalAlignment','center',...
    'FontName','Cambria');

% Get the middle value of the color range
midValue = mean(get(gca,'CLim'));

% Choose white or black for the text color of the strings so
% they can be easily seen over the background color
textColors = repmat(matperc(:) > midValue,1,3);
set(hStrings,{'Color'},num2cell(textColors,2));

% Setting the axis labels
set(gca,'XTick',1:numX,...
    'XTickLabel',xlab,...
    'YTick',1:numY,...
    'YTickLabel',ylab,...
    'TickLength',[0 0],...
    'FontName','Cambria');

end