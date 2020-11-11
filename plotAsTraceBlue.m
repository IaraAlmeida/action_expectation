function plotAsTraceBlue(evol,  xTickLabel)
hold on;
set(gcf,'DefaultAxesColorOrder',[0 0 1;0 1 0;1 0 0])
plot(evol, 'LineWidth', 3, 'Color', 'b', 'LineStyle', '--')
 
patch_time = [1:size(evol, 1) size(evol, 1):-1:1];
ph = patch(patch_time, [evol(:, 1)+err(:, 1); evol(end:-1:1, 1)-err(end:-1:1, 1)], [1 0 0]);
set(ph, 'FaceAlpha', 0.1, 'EdgeColor', [1 0 0], 'EdgeAlpha', 0.2)
ph = patch(patch_time, [evol(:, 2)+err(:, 2); evol(end:-1:1, 2)-err(end:-1:1, 2)], [0 0 1]);
set(ph, 'FaceAlpha', 0.1, 'EdgeColor', [0 0 1], 'EdgeAlpha', 0.2)

xTick = [];
l = size(evol, 1)./numel(xTickLabel);
for i=1:size(evol, 1) / sum(l)
    plot([i*sum(l) i*sum(l)], [-0.3 0.3], 'k--');
    plot([i*sum(l) i*sum(l)]+1, [-0.3 0.3], 'k--');
    xTick(end+1) = (i*sum(l))/2 + (i-1)*sum(l) /2;
end

hold off;
axis tight;
set(gca, 'xTick', xTick);
set(gca, 'xTickLabel', xTickLabel);


end