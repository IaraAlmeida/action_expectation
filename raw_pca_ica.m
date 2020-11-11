function[] = raw_pca_ica( ftdata )

%% 0. Average trials

ftdata_conc = ft_nirs_transform_ODs([], ftdata);

cfg = [];
cfg.demean = 'yes';
cfg.baselinewindow = [-2 0];
ftdata_conc_demeaned = ft_preprocessing(cfg, ftdata_conc);

cfg = [];
ftdata_tl = ft_timelockanalysis(cfg, ftdata_conc_demeaned);


figure('Name','Raw Data');
nrows = ceil(sqrt(numel(ftdata_tl.label)/2));
ncols = ceil(numel(ftdata_tl.label)/nrows/2);
maxyval = max(abs(ftdata_tl.avg(:)));
for i=1:2:numel(ftdata_tl.label)
  subplot(nrows, ncols, ceil(i/2))
  plot(ftdata_tl.time, ftdata_tl.avg(i+1, :), ftdata_tl.time, ftdata_tl.avg(i, :));
  title([ftdata_tl.label{i} ', ' ftdata_tl.label{i+1}] );  
  axis tight;
  ylim([-maxyval maxyval]);
end


 
for i=1:2:numel(ftdata_tl.label)
  subplot(nrows, ncols, ceil(i/2)) 
  % plotting variance as shaded area  
  patch_time = [ftdata_tl.time fliplr(ftdata_tl.time)];
  
  ph = patch(patch_time, [ftdata_tl.avg(i+1, :)+ftdata_tl.var(i+1, :) fliplr(ftdata_tl.avg(i+1, :)-ftdata_tl.var(i+1, :))], [0 0 1]);
  set(ph, 'FaceAlpha', 0.1, 'EdgeAlpha', 0.2)
  set(ph, 'FaceColor', [0 0 1]);
  
  ph = patch(patch_time, [ftdata_tl.avg(i, :)+ftdata_tl.var(i, :) fliplr(ftdata_tl.avg(i, :)-ftdata_tl.var(i, :))], [1 0 0]);
  set(ph, 'FaceAlpha', 0.1, 'EdgeAlpha', 0.2)
  set(ph, 'FaceColor', [1 0 0]);

  axis tight;
  ylim([-maxyval maxyval]);
end



%% 2. PCA

%run pca 

cfg = [];
cfg.method = 'pca';  %cfg.method       = 'runica', 'fastica', 'binica', 'pca', 'svd', 'jader', 'varimax', 'dss', 'cca', 'sobi', 'white' or 'csp' (default = 'runica')
ftdata_pca = ft_componentanalysis(cfg, ftdata_conc_demeaned);

cfg = [];
cfg.viewmode = 'vertical';
cfg.preproc.demean = 'yes';
cfg.allowoverlap = 'yes';
ft_databrowser(cfg, ftdata_pca);

%compute total variance of components and the calculate their contribution
totalvar = var(ftdata_pca.trial{1}, 0, 2);
pcontrib = totalvar ./ sum(totalvar);
cumcontrib = cumsum(pcontrib);

figure('Name', 'Contribution Function of Components of PCA to Variance')
plot(cumcontrib)
yline(0.97)
text(50, 0.95,'97% of Variance')

%97%_______________________________________________________________________
pc97 = cumcontrib < 0.97;

cfg = [];
cfg.component = ftdata_pca.label(~pc97);
ftdata_97 = ft_rejectcomponent(cfg, ftdata_pca);

ftdata_conc = ft_nirs_transform_ODs([], ftdata_97);

cfg = [];
cfg.demean = 'yes';
cfg.baselinewindow = [-2 0];
ftdata_conc_demeaned = ft_preprocessing(cfg, ftdata_conc);

cfg = [];
ftdata_tl = ft_timelockanalysis(cfg, ftdata_conc_demeaned);


figure('Name','PCA with 97%var');
nrows = ceil(sqrt(numel(ftdata_tl.label)/2));
ncols = ceil(numel(ftdata_tl.label)/nrows/2);
maxyval = max(abs(ftdata_tl.avg(:)));
for i=1:2:numel(ftdata_tl.label)
  subplot(nrows, ncols, ceil(i/2))
  plot(ftdata_tl.time, ftdata_tl.avg(i+1, :), ftdata_tl.time, ftdata_tl.avg(i, :));
  title([ftdata_tl.label{i} ', ' ftdata_tl.label{i+1}] );  
  axis tight;
  ylim([-maxyval maxyval]);
end


 
for i=1:2:numel(ftdata_tl.label)
  subplot(nrows, ncols, ceil(i/2)) 
  % plotting variance as shaded area  
  patch_time = [ftdata_tl.time fliplr(ftdata_tl.time)];
  
  ph = patch(patch_time, [ftdata_tl.avg(i+1, :)+ftdata_tl.var(i+1, :) fliplr(ftdata_tl.avg(i+1, :)-ftdata_tl.var(i+1, :))], [0 0 1]);
  set(ph, 'FaceAlpha', 0.1, 'EdgeAlpha', 0.2)
  set(ph, 'FaceColor', [0 0 1]);
  
  ph = patch(patch_time, [ftdata_tl.avg(i, :)+ftdata_tl.var(i, :) fliplr(ftdata_tl.avg(i, :)-ftdata_tl.var(i, :))], [1 0 0]);
  set(ph, 'FaceAlpha', 0.1, 'EdgeAlpha', 0.2)
  set(ph, 'FaceColor', [1 0 0]);

  axis tight;
  ylim([-maxyval maxyval]);
end



%% 3. ICA

%run ICA without short channels

cfg = [];
cfg.method = 'runica';  %cfg.method       = 'runica', 'fastica', 'binica', 'pca', 'svd', 'jader', 'varimax', 'dss', 'cca', 'sobi', 'white' or 'csp' (default = 'runica')
ftdata_ica = ft_componentanalysis(cfg, ftdata_conc_demeaned);

cfg = [];
cfg.viewmode = 'vertical';
cfg.preproc.demean = 'yes';
cfg.allowoverlap = 'yes';
ft_databrowser(cfg, ftdata_ica);

%compute total variance of components and the calculate their contribution
totalvar = var(ftdata_ica.trial{1}, 0, 2);
pcontrib = totalvar ./ sum(totalvar);
cumcontrib = cumsum(pcontrib);

figure('Name', 'Contribution Function of Components of ICA (without SC) to Variance')
plot(cumcontrib)
yline(0.97)
text(50, 0.95,'97% of Variance')
yline(0.80)
text(50, 0.75,'80% of Variance')

%For consistency 97%, but according to the graph 80% looks better 


%97%_______________________________________________________________________
pc97 = cumcontrib < 0.97;

% pc97 = cumcontrib < 0.80;

cfg = [];
cfg.component = ftdata_ica.label(~pc97);
ftdata_97 = ft_rejectcomponent(cfg, ftdata_ica);

ftdata_conc = ft_nirs_transform_ODs([], ftdata_97);

cfg = [];
cfg.demean = 'yes';
cfg.baselinewindow = [-2 0];
ftdata_conc_demeaned = ft_preprocessing(cfg, ftdata_conc);

cfg = [];
ftdata_tl = ft_timelockanalysis(cfg, ftdata_conc_demeaned);


figure('Name','ICA with 97%var');
nrows = ceil(sqrt(numel(ftdata_tl.label)/2));
ncols = ceil(numel(ftdata_tl.label)/nrows/2);
maxyval = max(abs(ftdata_tl.avg(:)));
for i=1:2:numel(ftdata_tl.label)
  subplot(nrows, ncols, ceil(i/2))
  plot(ftdata_tl.time, ftdata_tl.avg(i+1, :), ftdata_tl.time, ftdata_tl.avg(i, :));
  title([ftdata_tl.label{i} ', ' ftdata_tl.label{i+1}] );  
  axis tight;
  ylim([-maxyval maxyval]);
end


 
for i=1:2:numel(ftdata_tl.label)
  subplot(nrows, ncols, ceil(i/2)) 
  % plotting variance as shaded area  
  patch_time = [ftdata_tl.time fliplr(ftdata_tl.time)];
  
  ph = patch(patch_time, [ftdata_tl.avg(i+1, :)+ftdata_tl.var(i+1, :) fliplr(ftdata_tl.avg(i+1, :)-ftdata_tl.var(i+1, :))], [0 0 1]);
  set(ph, 'FaceAlpha', 0.1, 'EdgeAlpha', 0.2)
  set(ph, 'FaceColor', [0 0 1]);
  
  ph = patch(patch_time, [ftdata_tl.avg(i, :)+ftdata_tl.var(i, :) fliplr(ftdata_tl.avg(i, :)-ftdata_tl.var(i, :))], [1 0 0]);
  set(ph, 'FaceAlpha', 0.1, 'EdgeAlpha', 0.2)
  set(ph, 'FaceColor', [1 0 0]);

  axis tight;
  ylim([-maxyval maxyval]);
end

end
