function plotAsTrace(evol, err, xTickLabel)

set(gcf,'DefaultAxesColorOrder',[1 0 0;0 0 1])
%set(gcf,'DefaultAxesLineStyle',{'-', '--'})
plot(evol, 'LineWidth', 3)
hold on;

if ~isempty(err)
  for i=1:size(evol, 2)
    patch_time = [1:size(evol, 1) size(evol, 1):-1:1];
    ph = patch(patch_time, [evol(:, i)+err(:, i); evol(end:-1:1, i)-err(end:-1:1, i)], [1 0 0]);
    set(ph, 'FaceAlpha', 0.1, 'EdgeAlpha', 0.2)
    if mod(i,2)==0
      set(ph, 'FaceColor', [0 0 1]);
    else
      set(ph, 'FaceColor', [1 0 0]);
    end
  end
end

if exist('xTickLabel', 'var')
  xTick = [];
  l = size(evol, 1)./numel(xTickLabel);
  mini = min(evol) /2;
  maxi = max(evol) *2;
  for i=1:size(evol, 1) / sum(l)
    plot([i*sum(l) i*sum(l)], [mini maxi], 'k--');
    plot([i*sum(l) i*sum(l)]+1, [mini maxi], 'k--');
    xTick(end+1) = (i*sum(l))/2 + (i-1)*sum(l) /2;
  end

  hold off;
  axis tight;
  set(gca, 'xTick', xTick);
  set(gca, 'xTickLabel', xTickLabel);
else  
  hold off;
  axis tight;
end

end