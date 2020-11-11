%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        Video creation                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
infoVar;

%% reading file
cfg = [];
cfg.dataset = 'DATA//sub2.oxy3';
cfg.demean  = 'yes';
[data] = ft_preprocessing(cfg);

cfg = [];
cfg.channel = ft_channelselection('R*', data.label);
NIRS = ft_selectdata(cfg, data);
dataP=NIRS;
%% ADD accelerometer
cfg = [];
cfg.channel = ft_channelselection({'A*','-ADC001','-ADC002','-ADC003','-ADC004', '-ADC008'}, data.label);
Acc = ft_selectdata(cfg, data);

load('DATA//S_Npre_02.mat')
Acc.trial{1}= nirs_data.ADvalues(:,[5 6 7]).';

%% preprocessing
% cfg             = [];
% cfg.dpf         = 5; %redo for proper dpf 
% dataP           = ft_nirs_transform_ODs(cfg, NIRS); % IN MICROMOLAR

cfg = [];
data_merged =  ft_appenddata(cfg, dataP, Acc);

%% Find events
cfg                                   = [];
cfg.dataset                           = 'DATA//sub2.oxy3';
cfg.trialdef.eventtype                = 'event';
[EVENTS]                              = ft_definetrial(cfg);

%remove trigger not event
eliminate = ismember({EVENTS.event.type}, {'event'}); %remove trigger not event
EVENTS.event = EVENTS.event(eliminate);

eliminate2 = ismember({EVENTS.event.value}, {'LSL 1','LSL 2','LSL '});
EVENTS.event = EVENTS.event(~eliminate2);


%% Video creation
begtime  = 150;
endtime  = 165-1/data_merged.fsample;% seconds minus one sample
increment = 0.25; % stepwise in seconds
vidObj = VideoWriter('databrowser', 'MPEG-4');
vidObj.FrameRate = 1/increment;
vidObj.Quality = 100;
open(vidObj);
% prevent too much feedback info to be printed on screen
ft_debug off
ft_info off
ft_notice off
% make a figure with proper size
figh = figure;
set(figh, 'WindowState', 'maximized');
count=1;
while (endtime < data_merged.time{1}(end)) && ishandle(figh)
    cfg = [];
    cfg.toilim              = [begtime endtime];
    cfg.trackcallinfo       = 'no';
    cfg.showcallinfo        = 'no';
    data_piece              = ft_redefinetrial(cfg, data_merged);
    
    cfg = [];
    cfg.figure              = 'no';   % (re)use the existing figure
    cfg.trackcallinfo       = 'no'; % prevent too much feedback info to be printed on screen
    cfg.showcallinfo        = 'no'; % prevent too much feedback info to be printed on screen
    cfg.viewmode            = 'vertical';
    cfg.event               = EVENTS.event;
    cfg.ploteventlabels     = 'colorvalue';
    cfg.plotlabels          = 'yes';
    cfg.fontsize            = 6.1;
    cfg.continuous          = 'yes';
    cfg.blocksize           = 15;
    cfg.nirsscale           = 55;
    cfg.mychan              = {'ADC005','ADC006','ADC007'};
    cfg.mychanscale         = [5,10,10];
    cfg.preproc.demean      = 'yes';
    cfg.linecolor=[1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1;
    1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1;
    1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1;
    1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1;
    1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1;0,0,0;0,1,0;0.9290, 0.6940, 0.1250];
    cfg.linewidth           = 1.16;
    cfg.verticalpadding     =0.09;
    
    
    ft_databrowser(cfg, data_piece); 
    set(gca, 'XGrid', 'on');
    currFrame = getframe(gcf);
    writeVideo(vidObj,currFrame);
    
    begtime = begtime + increment;
    endtime = endtime + increment;
    
    disp(string(count));
    count=count+1;
end
% Close the file
close(vidObj);



%% try scale
cfg = [];
cfg.toilim              = [150 data_merged.time{1}(end)];
cfg.trackcallinfo       = 'no';
cfg.showcallinfo        = 'no';
data_piece              = ft_redefinetrial(cfg, data_merged);

cfg = [];
cfg.viewmode            = 'vertical';
cfg.event               = EVENTS.event;
cfg.ploteventlabels     = 'colorvalue';
cfg.plotlabels          = 'yes';
cfg.fontsize            = 6.1;
cfg.continuous          = 'yes';
cfg.blocksize           = 15;
cfg.nirsscale           = 6000;
cfg.mychan              = {'ADC005','ADC006','ADC007'};
cfg.mychanscale         = [5,5,5];
cfg.ylim = 'maxmin';
cfg.preproc.demean      = 'yes';
cfg.linecolor=[1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1;
    1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1;
    1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1;
    1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1;
    1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1; 1, 0, 0;0, 0, 1;0,0,0;0,1,0;0.9290, 0.6940, 0.1250];
cfg.linewidth           = 1.16;
cfg.verticalpadding     =0.09;

ft_databrowser(cfg, data_piece); 
% set(gca, 'XGrid', 'on');


%% try acc
cfg.blocksize           = 60;
cfg.viewmode            = 'vertical';
cfg.mychan              = {'ADC005','ADC006','ADC007'};
% cfg.mychanscale         = [0.2,0.5,1];
cfg.linecolor = [0,0,0;0,1,0;0.9290, 0.6940, 0.1250];
ft_databrowser(cfg, Acc); 



    