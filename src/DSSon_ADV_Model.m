% DSSon_ADV_Model.m
%
%   Characteristic Direct Sonification
%   for FRED-Data
%
%   Advanced Model
%
%   by Robert Höldrich and Paul Vickers
%   -----------------------------------
%
%   segments are determined by the crossing points between the FRED signal
%   and the individual slowly time-varying target (weighted mean of nominal target,
%   i.e.0.4 Hz, and slowly varying indiviual mean)
%
%   kappa=15;
%
%   DELTA=5; stretched sonic events by a factor of 3;
%   additional dilation modulation for segments beyond the maximum range of 0.2Hz - 0.6Hz.
%
%   amplitude modulator based on a threshold function combined with |x_i|,PHI_ring=1.0
%   envelope-based AM for segments beyond the maximum range of 0.2Hz - 0.6Hz.
%
%   alpha=2, beta=2
%
%   timbre:
%       pure sine tone for segments within 0.2Hz <=f <=0.6Hz
%       harmonic complex for segments exhibiting excursions >0.6Hz
%       subharmonic complex for segments exhibiting excursions <0.2Hz

clear all
close all

% plot figures? Yes: plot_flag=1, No: plot_flag=0
plot_flag=1;

% samping rate in Hz of output file
fs=44100;

% time compression factor "kappa"
% i.e. duration of sonification divided by duration of data
kappa=15;

for sound=1:3
    sound
    switch sound
        case 1
            wav_name='DSSon_ADV_A_e.wav';
            %dd=wavread('DA2.wav'); % - MATLAB 2011 syntax
            dd=audioread('DA2.wav');
            fs_data=100;
            d=resample(dd,fs,fs_data*kappa)*2; %the factor of 2 is due to our coding of the frequency values in the wav-file
        case 2
            wav_name='DSSon_ADV_B.wav';
            %dd=wavread('DB1.wav'); % - MATLAB 2011 syntax
            dd=audioread('DB1.wav');
            fs_data=100;
            d=resample(dd,fs,fs_data*kappa)*2; %the factor of 2 is due to our coding of the frequency values in the wav-file
        case 3
            wav_name='DSSon_ADV_A_n.wav';
            %dd=wavread('DA1.wav'); % - MATLAB 2011 syntax
            dd=audioread('DA1.wav');
            fs_data=100;
            d=resample(dd,fs,fs_data*kappa)*2; %the factor of 2 is due to our coding of the frequency values in the wav-file
    end
    
    % low-pass filter to calculate the slowly varying indiviual mean
    mean_d=filtfilt(0.0001,[1 -0.9999],d);
    target_d=0.4;
    
    %individual slowly time-varying target: weighted mean of nominal target,
    %i.e.0.4 Hz, and slowly varying indiviual mean
    t_d=0.2*target_d+0.8*mean_d;
    
    % plot data values and trend signal
    if plot_flag
        lt=60;
        ttt=1:length(d);
        ttt=ttt/fs*kappa;
        % Create figure
        width=660;
        height=350;
        x0=300;
        y0=300;
        figure1 = figure('Units','pixels',...
            'Position',[x0 y0 width height],...
            'PaperPositionMode','auto');
        axes1 = axes('Parent',figure1,...
            'FontUnits','points',...
            'FontWeight','normal',...
            'YTickLabel',{'0.0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1.0'},...
            'YTick',[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7],...
            'XTick',[0 5 10 15 20 25 30 35 40 45 50 55 60],...
            'Units','pixels',...
            'Position',[52 42 600 300],...
            'FontSize',14,...
            'FontName','Times','LineWidth',1.5);
        %% Uncomment the following line to preserve the X-limits of the axes
        % xlim(axes1,[0 60]);
        %% Uncomment the following line to preserve the Y-limits of the axes
        % ylim(axes1,[0.1 0.7]);
        box(axes1,'on');
        grid(axes1,'on');
        hold(axes1,'all');
        
        % Create multiple lines using matrix input to plot
        % plot1 = plot(X1,YMatrix1,'Parent',axes1,'Color',[0 0 0]);
        % set(plot1(1),'LineWidth',1,'DisplayName','data');
        % set(plot1(2),'LineWidth',3,'LineStyle','--','DisplayName','trend');
        plot(ttt,d,'k','LineWidth',1.4,'DisplayName',' data');
        plot(ttt,t_d,'k--','LineWidth',3,'DisplayName',' trend');
        axis([0 lt 0.1 0.7]);
        
        % Create xlabel
        % set(gca,'layer','top');
        xlabel('Time (s)','FontSize',16,'FontName','Times','Position',[30 0.06] );
        %       xlabel('seconds','FontSize',18,'FontName','Times', 'interpreter','latex');
        % Create ylabel
        ylabel('Revolution rate (Hz)','FontSize',16,'FontName','Times','Position',[-2.6 0.4] );%'Position',[10 15 ] );
        
        % Create legend
        legend1 = legend(axes1,'show');
        set(legend1,'Units','pixels','FontSize',16);
    end
    
    % determination of the cutting points
    d_ex_mean=d-t_d;
    int_points=find(d_ex_mean(1:end-1).*d_ex_mean(2:end)<0);
    int_points=[0;int_points;length(d_ex_mean)];
    l_seg=length(int_points)-1;
    
    if d_ex_mean(1)>0
        n_pos=floor((l_seg+1)/2);
        n_neg=l_seg-n_pos;
        pos_segments=zeros(n_pos,2);
        for ii=1:n_pos
            pos_segments(ii,1)=int_points(ii*2-1)+1;
            pos_segments(ii,2)=int_points(ii*2);
        end
        neg_segments=zeros(n_neg,2);
        for ii=1:n_neg
            neg_segments(ii,1)=int_points(2*ii)+1;
            neg_segments(ii,2)=int_points(2*ii+1);
        end
    else
        n_neg=floor((l_seg+1)/2);
        n_pos=l_seg-n_neg;
        neg_segments=zeros(n_neg,2);
        for ii=1:n_neg
            neg_segments(ii,1)=int_points(ii*2-1)+1;
            neg_segments(ii,2)=int_points(ii*2);
        end
        pos_segments=zeros(n_pos,2);
        for ii=1:n_pos
            pos_segments(ii,1)=int_points(2*ii)+1;
            pos_segments(ii,2)=int_points(2*ii+1);
        end
    end
    % END Determination of cutting points
    
    out_file=zeros(length(d_ex_mean)+100000,1);
    
    % to determine DELTA=stretch_d/strech_u*kappa
    stretch_u=3;
    stretch_d=1;
    x_mean_h=resample(t_d,stretch_u,stretch_d);
    x_mean_h=[x_mean_h;ones(10,1)*target_d]; % just to prevent artefacts from upsampling
    
    %reference frequencies
    f_ref_pos=400;
    f_ref_neg=300;
    
    % alpha und beta, the transposition parameters
    alpha=2;
    beta=2;
    
    % power law distortion factor PHI_ring
    PHI_ring=1.;
    
    % threshold epsilon
    threshold=0.1;
    
    % window for fade out of the envelipe tail to prevent clicks
    NN=440;
    w2=window(@hann,2*NN);
    
    % dilation modulation
    sigma=1;
    l_c1=1; % optional exponent for the dilation transformation
    
    % magnitude difference for the timbre operator to introduce (sub)harmonic complexes
    % i.e. for the nominal target x_target=0.4Hz, lev = | 0.6 Hz - x_target | = | x_target - 0.2 Hz|
    lev=0.2;
    
    % timbre parameters
    J=5;
    nu=-2;
    
    for ii=1:n_pos-1 % only up to pos-1, because of discontinuity at the end of some data vectors.
        x=resample(d_ex_mean( pos_segments(ii,1):pos_segments(ii,2)),stretch_u,stretch_d);
        x_mean=x_mean_h(floor(pos_segments(ii,1)*stretch_u/stretch_d):floor(pos_segments(ii,2)*stretch_u/stretch_d)+2);
        % to cure dimensionality nonsense
        if pos_segments(ii,1)==pos_segments(ii,2)
            x=x';
            x_mean=x_mean';
        end
        f_i=f_ref_pos*2.^(alpha*t_d(pos_segments(ii,1)))*2.^(beta*x);
        cum_phi=cumsum(2*pi*f_i/fs);
        x_sound=(max(0,max(abs(x)-threshold)))^0.02*abs(x).^PHI_ring.*sin(cum_phi);
        
        % rich timbre for segments exceeding 0.6 Hz
        overshot=max(max(0,x+x_mean(1:length(x))-0.6));
        if overshot
            overshot_area=max(lev,pi*4/target_d*sum(abs(x))/(fs*stretch_u/stretch_d));
            % we used a clipping of the dilation modulation (maximum factor of 8) which is not
            % really necessary
            area_stretch=round(min(80,(sigma*(max(lev,overshot_area)/lev)^l_c1)*10));
            % just for printing
            if overshot_area>lev
                overshot_area;
                area_stretch;
            end
            x=resample(x,area_stretch,10);
            f_i=f_ref_pos*2.^(alpha*t_d(pos_segments(ii,1)))*2.^(beta*x);
            cum_phi=cumsum(2*pi*f_i/fs);
            t=(1:length(x))';
            w3=7.6*t.*exp(-7.6*t/length(x)+1)/length(x);
            for jj=1:J
                w3(end-min(NN,length(x))+1:end)=w3(end-min(NN,length(x))+1:end).*w2(end-min(NN,length(x))+1:end);
                x_sound=0.5*max(abs(x))*jj^nu*w3.*sin(jj*cum_phi);
                out_file(pos_segments(ii,1):pos_segments(ii,1)+length(x_sound)-1)=out_file(pos_segments(ii,1):pos_segments(ii,1)+length(x_sound)-1)+x_sound;
            end
        else
            out_file(pos_segments(ii,1):pos_segments(ii,1)+length(x_sound)-1)=out_file(pos_segments(ii,1):pos_segments(ii,1)+length(x_sound)-1)+x_sound;
        end
        % END rich timbre
    end
    for ii=1:n_neg-1
        x=resample(d_ex_mean(neg_segments(ii,1):neg_segments(ii,2)),stretch_u,stretch_d);
        x_mean=x_mean_h(floor(neg_segments(ii,1)*stretch_u/stretch_d):floor(neg_segments(ii,2)*stretch_u/stretch_d)+2);
        % to cure dimensionality nonsense
        if neg_segments(ii,1)==neg_segments(ii,2)
            x=x';
            x_mean=x_mean';
        end
        f_i=f_ref_neg*2.^(alpha*t_d(neg_segments(ii,1)))*2.^(beta*x);
        cum_phi=cumsum(2*pi*f_i/fs);
        x_sound=(max(0,max(abs(x)-threshold)))^0.02*abs(x).^PHI_ring.*sin(cum_phi);
        
        % rich timbre for segments below 0.2 Hz
        undershot=min(min(0,x+x_mean(1:length(x))-0.2));
        if abs(undershot)
            overshot_area=max(lev,pi*4/target_d*sum(abs(x))/(fs*stretch_u/stretch_d));
            % we used a clipping of the dilation modulation (maximum factor of 8) which is not
            % really necessary
            area_stretch=round(min(80,(sigma*(max(lev,overshot_area)/lev))*10));
            % just for printing
            if overshot_area>lev
                overshot_area;
                area_stretch;
            end
            x=resample(x,area_stretch,10);
            f_i=f_ref_neg*2.^(alpha*t_d(neg_segments(ii,1)))*2.^(beta*x);
            cum_phi=cumsum(2*pi*f_i/fs);
            t=(1:length(x))';
            w3=7.6*t.*exp(-7.6*t/length(x)+1)/length(x);
            for jj=1:J
                w3(end-min(NN,length(x))+1:end)=w3(end-min(NN,length(x))+1:end).*w2(end-min(NN,length(x))+1:end);
                x_sound=0.7*max(abs(x))*jj^nu*w3.*sin(1/jj*cum_phi);
                out_file(neg_segments(ii,1):neg_segments(ii,1)+length(x_sound)-1)=out_file(neg_segments(ii,1):neg_segments(ii,1)+length(x_sound)-1)+x_sound;
            end
        else
            out_file(neg_segments(ii,1):neg_segments(ii,1)+length(x_sound)-1)=out_file(neg_segments(ii,1):neg_segments(ii,1)+length(x_sound)-1)+x_sound;
        end
        % END rich timbre
    end
    %wavwrite(0.7*out_file,fs,16,wav_name); % MATLAB 2011 syntax
    audiowrite(wav_name, 0.7*out_file, fs);
    if plot_flag
        %wind=hanning(2048);
        % only for Chis ADV
        wind=hanning(2048);
        [S,F,TT,P] = spectrogram(out_file, wind,length(wind)-256,8092,fs);
        width=1320;
        height=700;
        x0=100;
        y0=100;
        figure2 = figure('Units','pixels',...
            'Position',[x0 y0 width height],...
            'PaperPositionMode','auto','InvertHardcopy','off',...
            'Colormap',[1 1 1;0.98412698507309 0.98412698507309 0.98412698507309;0.968253970146179 0.968253970146179 0.968253970146179;0.952380955219269 0.952380955219269 0.952380955219269;0.936507940292358 0.936507940292358 0.936507940292358;0.920634925365448 0.920634925365448 0.920634925365448;0.904761910438538 0.904761910438538 0.904761910438538;0.888888895511627 0.888888895511627 0.888888895511627;0.873015880584717 0.873015880584717 0.873015880584717;0.857142865657806 0.857142865657806 0.857142865657806;0.841269850730896 0.841269850730896 0.841269850730896;0.825396835803986 0.825396835803986 0.825396835803986;0.809523820877075 0.809523820877075 0.809523820877075;0.793650805950165 0.793650805950165 0.793650805950165;0.777777791023254 0.777777791023254 0.777777791023254;0.761904776096344 0.761904776096344 0.761904776096344;0.746031761169434 0.746031761169434 0.746031761169434;0.730158746242523 0.730158746242523 0.730158746242523;0.714285731315613 0.714285731315613 0.714285731315613;0.698412716388702 0.698412716388702 0.698412716388702;0.682539701461792 0.682539701461792 0.682539701461792;0.666666686534882 0.666666686534882 0.666666686534882;0.650793671607971 0.650793671607971 0.650793671607971;0.634920656681061 0.634920656681061 0.634920656681061;0.61904764175415 0.61904764175415 0.61904764175415;0.60317462682724 0.60317462682724 0.60317462682724;0.58730161190033 0.58730161190033 0.58730161190033;0.571428596973419 0.571428596973419 0.571428596973419;0.555555582046509 0.555555582046509 0.555555582046509;0.539682567119598 0.539682567119598 0.539682567119598;0.523809552192688 0.523809552192688 0.523809552192688;0.507936537265778 0.507936537265778 0.507936537265778;0.492063492536545 0.492063492536545 0.492063492536545;0.476190477609634 0.476190477609634 0.476190477609634;0.460317462682724 0.460317462682724 0.460317462682724;0.444444447755814 0.444444447755814 0.444444447755814;0.428571432828903 0.428571432828903 0.428571432828903;0.412698417901993 0.412698417901993 0.412698417901993;0.396825402975082 0.396825402975082 0.396825402975082;0.380952388048172 0.380952388048172 0.380952388048172;0.365079373121262 0.365079373121262 0.365079373121262;0.349206358194351 0.349206358194351 0.349206358194351;0.333333343267441 0.333333343267441 0.333333343267441;0.31746032834053 0.31746032834053 0.31746032834053;0.30158731341362 0.30158731341362 0.30158731341362;0.28571429848671 0.28571429848671 0.28571429848671;0.269841283559799 0.269841283559799 0.269841283559799;0.253968268632889 0.253968268632889 0.253968268632889;0.238095238804817 0.238095238804817 0.238095238804817;0.222222223877907 0.222222223877907 0.222222223877907;0.206349208950996 0.206349208950996 0.206349208950996;0.190476194024086 0.190476194024086 0.190476194024086;0.174603179097176 0.174603179097176 0.174603179097176;0.158730164170265 0.158730164170265 0.158730164170265;0.142857149243355 0.142857149243355 0.142857149243355;0.126984134316444 0.126984134316444 0.126984134316444;0.111111111938953 0.111111111938953 0.111111111938953;0.095238097012043 0.095238097012043 0.095238097012043;0.0793650820851326 0.0793650820851326 0.0793650820851326;0.0634920671582222 0.0634920671582222 0.0634920671582222;0.0476190485060215 0.0476190485060215 0.0476190485060215;0.0317460335791111 0.0317460335791111 0.0317460335791111;0.0158730167895556 0.0158730167895556 0.0158730167895556;0 0 0],...
            'Color',[1 1 1]);
        axes1 = axes('Parent',figure2,...
            'YTickLabel',{'50Hz','100Hz','200Hz','400Hz','800Hz','1.6kHz','3.2kHz', '6.4kHz'},...
            'YTick',[50 100 200 400 800 1600 3200 6400],...
            'YScale','log',...
            'YMinorTick','on',...
            'YMinorGrid','off',...
            'XTickLabel',{'0','1','2','3','4','5','6','7','8','9','10'},...
            'XTick',0:1:10,...
            'XMinorTick','off',...
            'Units','pixels',...
            'Position',[116 72 1192 610],...
            'FontSize',28,...
            'FontName','Times','LineWidth',3,...
            'GridLineStyle','- -',...
            'CLim',[-80 -30]);
        %% Uncomment the following line to preserve the X-limits of the axes
        xlabel('Time (s)','FontSize',28,'Position',[2 80]);
        set(gca,'layer','top');
        xlim(axes1,[0 4]);
        for ii=0:5
            line([0;4],[100*2^ii;100*2^ii],'LineWidth',0.5,'LineStyle','- -','Color',0*[1 1 1]);
        end
        for ii=1:3
            line([ii;ii],[100;3200],'LineWidth',0.5,'LineStyle','- -','Color',0*[1 1 1]);
        end
        %% Uncomment the following line to preserve the Y-limits of the axes
        ylim(axes1,[100 3200]);
        box(axes1,'on');
        grid(axes1,'off');
        hold(axes1,'all');
        %alpha(axes1,1);
        % Create surf
        %subplot(1,2,2)
        %subplot('Parent',axes1)
        surf(TT,F,10*log10(P+0.00000001),'Parent',axes1,'EdgeColor','none');
    end
end
