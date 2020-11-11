%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    FOR T                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Triggers.Omission = {'LSL omission_single'};
Triggers.Action = {'LSL rigth_o_single', 'LSL top_o_single', 'LSL left_o_single',...
    'LSL rigth_g_single', 'LSL top_g_single', 'LSL left_g_single'};

fileList = dir('C:\Users\Daphne\Desktop\PilotTommasoAugust\*.oxy4');

for x = 1:length(fileList)
    sub = fileList(x).name;
    name = strrep(sub,'.oxy4','');
    
    %% reading
    cfg = [];
    cfg.dataset = ['C:\Users\Daphne\Desktop\PilotTommasoAugust\' sub];
    [data] = ft_preprocessing(cfg);

    cfg = [];
    cfg.channel = ft_channelselection('R*', data.label);
    NIRS = ft_selectdata(cfg, data);

    cfg = [];
    cfg.channel = ft_channelselection('A*', data.label);
    Acc = ft_selectdata(cfg, data);
    
    %% preprocessing
    cfg             = [];
    cfg.dpf         = 5; %redo for proper dpf 
    dataP           = ft_nirs_transform_ODs(cfg, NIRS); % IN MICROMOLAR

    cfg = [];
    cfg.bpfilter = 'yes';
    cfg.bpfilttype ='firws';
    cfg.bpfreq = [0.01 0.1];
    data_filtered = ft_preprocessing(cfg, dataP);
    
    %% Epochs
    cfg                                   = [];
    cfg.dataset                           = ['C:\Users\Daphne\Desktop\PilotTommasoAugust\' sub];
    cfg.trialdef.eventtype                = 'event';
    cfg.trialdef.eventvalue               = [Triggers.Omission Triggers.Action];
    cfg.trialdef.prestim                  = -2;
    cfg.trialdef.poststim                 = 15; 
    [def_trial]                           = ft_definetrial(cfg);

    %remove trigger not event
    eliminate = ismember({def_trial.event.type}, {'event'}); %remove trigger not event
    def_trial.event = def_trial.event(eliminate);

    eliminate2 = ismember({def_trial.event.value}, {'LSL 1','LSL 2','LSL '});
    def_trial.event = def_trial.event(~eliminate2);

    %select the triggers
    eliminate3 = ismember({def_trial.event.value}, [Triggers.Action, Triggers.Omission]);
    def_trial.event = def_trial.event(eliminate3);

    data_epoch = ft_redefinetrial(def_trial, data_filtered);

    %baseline correction
    cfg= [];
    cfg.baselinewindow = [-inf 0];
    cfg.demean         = 'yes';
    cfg.channel        = 1:90;
    data_epoch         =  ft_preprocessing(cfg,data_epoch);


    %% reject artefact
    %Omission
    cfg                   = [];
    cfg.trials            = find(strcmp({def_trial.event.value}, Triggers.Omission));
    Omission              = ft_selectdata(cfg, data_epoch);
    
    %Presentation
    cfg                   = [];    
    single                = find(strcmp({def_trial.event.value}, 'LSL left_o_single'));
    single                = [single find(strcmp({def_trial.event.value}, 'LSL left_g_single'))];
    single                = [single find(strcmp({def_trial.event.value}, 'LSL top_o_single'))];
    single                = [single find(strcmp({def_trial.event.value}, 'LSL top_g_single'))];
    single                = [single find(strcmp({def_trial.event.value}, 'LSL right_o_single'))];
    single                = [single find(strcmp({def_trial.event.value}, 'LSL right_g_single'))];
    cfg.trials            = single;
    Presentation          = ft_selectdata(cfg, data_epoch);
    
    
    % mergind subjects
    if x == 1 
        P = Presentation;
        O = Omission;
    else
        cfg= [];
        P = ft_appenddata(cfg, P, Presentation);
        O = ft_appenddata(cfg, O, Omission);
    end
end


%% Prepare Layout
load('baby_head');


%% Timelock Analysis All
cfg                   = [];
cfg.channel           = 1:2:90;
[tomlock_O2Hb_o]      = ft_timelockanalysis(cfg, O);

cfg                   = [];
cfg.channel           = 1:2:90;
[tomlock_O2Hb_p]      = ft_timelockanalysis(cfg, P);

cfg                   = [];
cfg.channel           = 2:2:90; 
[tomlock_HHb_o]       = ft_timelockanalysis(cfg, O);

cfg                   = [];
cfg.channel           = 2:2:90; 
[tomlock_HHb_p]       = ft_timelockanalysis(cfg, P);

tomlock_HHb_o.label = tomlock_O2Hb_p.label;%quick fix to have same labels as layout
tomlock_HHb_p.label = tomlock_O2Hb_p.label;
baby_head.label     = tomlock_O2Hb_p.label;


%% Plot axial gradient results

cfg                   = [];
cfg.showlabels        = 'yes';
cfg.layout            = baby_head;
cfg.interactive       = 'yes';
cfg.linecolor         = 'rb';
cfg.ylim = [-5 5];
cfg.xlim = [-1 15];
cfg.layout.outline = {};
cfg.linewidth = 1;

figure;
subplot(2, 1, 1)
ft_multiplotER(cfg, tomlock_O2Hb_o, tomlock_HHb_o)
title('Omission');

subplot(2, 1, 2)
ft_multiplotER(cfg, tomlock_O2Hb_p, tomlock_HHb_p)
title('Presentation');


