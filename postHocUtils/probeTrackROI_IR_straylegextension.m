%% Set an ROI that avoids the leg, just gets the probe
% I think I only need 1 for now, but I'll keep the option for multiple
% (storing in cell vs matrix)

vid = VideoReader(trial.imageFile);
N = round(vid.Duration*vid.FrameRate);
h2 = postHocExposure(trial,N);
t = makeInTime(trial.params);
t_f = trial.params.durSweep-5*1/vid.FrameRate;

for cnt = 1:5
    frame = readFrame(vid);
end
frame = squeeze(frame(:,:,1));
if sum(frame(:)>10) < numel(frame)/1000
    startAt0 = true;
    t_i = 5*1/vid.FrameRate;
elseif isempty(strfind(trial.params.protocol,'Sweep'))
    startAt0 = false;
    t_i = 5*1/vid.FrameRate -trial.params.preDurInSec;
else
    t_i = 5*1/vid.FrameRate;
end 
frames = find(t(h2.exposure)>t_i & t(h2.exposure)<t_f);
N = length(frames);

kk = 0;
while kk<frames(1)
    kk = kk+1;
    
    readFrame(vid);
    continue
end

smooshedframe = double(readFrame(vid));
smooshedframe = squeeze(smooshedframe(:,:,1));
smooshedframe(:) = 0; 
readFrame(vid); readFrame(vid);

for jj = 1:4
    mov3 = double(readFrame(vid));
    smooshedframe = smooshedframe+mov3(:,:,1);
end
frame = smooshedframe/4;
for jj = 1:20
    mov3 = double(readFrame(vid));
    smooshedframe = smooshedframe+mov3(:,:,1);
end
smooshedframe = smooshedframe/24;

%% Smooth out the spot to show
if isfield(trial,'brightSpots2Smooth')
    for roi_ind = 1:length(trial.brightSpots2Smooth)
        spot = trial.brightSpots2Smooth{roi_ind};
        centroid = mean(spot,1); centroids = repmat(centroid,size(spot,1),1);
        annulus = (spot-centroids)*2+centroids;
                
        spotmask = poly2mask(spot(:,1),spot(:,2),size(smooshedframe,1),size(smooshedframe,2));
        annulusmask = poly2mask(annulus(:,1),annulus(:,2),size(smooshedframe,1),size(smooshedframe,2));
        annulusvals = smooshedframe(annulusmask&~spotmask);
        I = mean(annulusvals);
        
        frame(spotmask) = I;
        smooshedframe(spotmask) = I;
    end
end

%% Some knowledge

% Some knowledge about the probe: 
% The bar is long, longer than the glue will be.
% This means it will be in the image longer, further to the corner
% For now, the bar stretches back to the corner
% The bar is always the same width. If it's wider, then there was some
% motion. It cannot be thinner
% It will be close in neighboring frames
% the tangent line is the direction of motion, the bar line is the
% direction of the bar. 
% From one frame to the next, the number of profiles to compute might
% change

% Only look at when the light comes on
% From the tangent line, select out the ROI to be looking at.
% Some regions are going to be the same intensity the entire time (glue,
% leg)

%% Probe profile estimation
% Generate a series of points along the probe line

% loop through these points
%   get the improfile, centered on the probe line, with the points of
%   measurements at the same intervals

l = trial.forceProbe_line;
p = trial.forceProbe_tangent;

% probe_eval_points = turnLineIntoEvalPnts(l,p);
% recenter
l_0 = l - repmat(mean(l,1),2,1);
p_0 = p - mean(l,1);

% for my purposes, get the line equation (m,b)
m = diff(l(:,2))/diff(l(:,1));
b = l(1,2)-m*l(1,1);

% find y vector
barbar = l_0(2,:)/norm(l_0(2,:));

% project tangent point
p_scalar = barbar*p_0';

% find intercept, recenter
p_ = p_scalar*barbar+mean(l,1);

% rotate coordinates
R = [cos(pi/2) -sin(pi/2);
    sin(pi/2) cos(pi/2)];
l_r = (R*l_0')'/4;
upperright_ind = find(l_r(:,1)>l_r(:,2));
x = l_r(upperright_ind,:)/norm(l_r(upperright_ind,:));
l_r = l_r + repmat(p_,2,1);


%% now set up evaluation points
% find the edge of the image
if b<0
    p_edge = [-b/m 0];
else
    p_edge = [0  b];
end
l_eval = [p_;p_edge];

tangent_to_edge = l_eval - repmat(l_eval(1,:),2,1);
points2eval = (1:ceil(norm(tangent_to_edge(2,:))))-1;
barbar = tangent_to_edge(2,:)/norm(tangent_to_edge(2,:));

% eval points occur every pxl along l_eval
moveEvalPntsAlong = repmat(p_',1,length(points2eval))+barbar'*points2eval;

x_as_points = [0 0;x]+repmat(p_,2,1);
m_ = diff(x_as_points(:,2))/diff(x_as_points(:,1));
b_ = x_as_points(1,2)-m_*x_as_points(1,1);

p_to_edge_along_tangent = [p_;0 b_];
dist_to_edge(1) = sqrt(diff(p_to_edge_along_tangent(:,1))^2+diff(p_to_edge_along_tangent(:,1))^2);

p_to_edge_along_tangent = [p_;-b_/m_ 0];
dist_to_edge(2) = sqrt(diff(p_to_edge_along_tangent(:,1))^2+diff(p_to_edge_along_tangent(:,1))^2);

% evalpnts should start at the tangent intersection and go out from there,
% + and -
evalpnts_x = -ceil(max(dist_to_edge)):1:ceil(max(dist_to_edge));
evalpnts = x'*evalpnts_x;
% evalN = size(evalpnts,2);
% evalEnds = [evalpnts(:,1) evalpnts(:,end)];

xy = evalpnts+repmat(moveEvalPntsAlong(:,1),1,length(evalpnts));
xy = uint16(xy);
pos_idxs = xy(1,:)>0 & xy(2,:)>0;
evalpnts = evalpnts(:,pos_idxs);
evalpnts_x = evalpnts_x(pos_idxs);

ProfileMat = nan(length(moveEvalPntsAlong),size(evalpnts,2));
BackgroundProfiles = ProfileMat;
Rmap = nan(size(ProfileMat,1),size(ProfileMat,2));
Cmap = nan(size(ProfileMat,1),size(ProfileMat,2));

% move along line back to corner,
% xy = evalpnts+repmat(moveEvalPntsAlong(:,1),1,length(evalpnts));
% pos_idxs = xy(1,:)>0 & xy(2,:)>0;
% xy = xy(:,pos_idxs);
% l = line(xy(1,:),xy(2,:),'parent',dispax,'linestyle','none','marker','.','markerfacecolor',[1 1 1],'markeredgecolor',[1 1 1],'tag','samples');

% profileFigure = figure;
% set(profileFigure,'position',[1331 421 560 420]);
% profileAxes = subplot(1,1,1); hold(profileAxes,'on');
% I = impixel(smpd.sampledImage(:,:,1),xy(1,:),xy(2,:));
% % prfl = plot(evalpnts_x(pos_idxs),I(:,1),'k','parent',profileAxes);

for ep_idx = 1:size(moveEvalPntsAlong,2)
    xy = evalpnts+repmat(moveEvalPntsAlong(:,ep_idx),1,length(evalpnts));
    xy = uint16(xy);
    pos_idxs = xy(1,:)>0 & xy(2,:)>0;
    
    Rmap(ep_idx,pos_idxs) = xy(1,pos_idxs);
    Cmap(ep_idx,pos_idxs) = xy(2,pos_idxs);
    
    pos_idxs_i(pos_idxs) = find(pos_idxs);
    
    for rc = 1:size(xy,2)
        if xy(1,rc)>0 && xy(2,rc)>0
            ProfileMat(ep_idx,pos_idxs_i(rc)) = frame(xy(2,rc),xy(1,rc));
            BackgroundProfiles(ep_idx,pos_idxs_i(rc)) = smooshedframe(xy(2,rc),xy(1,rc));
        end
    end
    
    % set(prfl,'XData',evalpnts_x(pos_idxs),'YData',I(:,1));
    % drawnow
end

% slim down the profile mat and evalpnst
indices_gt4vals = sum(~isnan(ProfileMat),1)>4; % Want to average over 

evalpnts_x = evalpnts_x(indices_gt4vals);
evalpnts = evalpnts(:,indices_gt4vals);

BackgroundProfiles = BackgroundProfiles(:,indices_gt4vals);
Rmap = Rmap(:,indices_gt4vals);
Cmap = Cmap(:,indices_gt4vals);
ProfileMat = ProfileMat(:,indices_gt4vals);

%quick check on the profileIndices: in third dim, all entries should either
%be nan or real
% sum(sum(~isnan(ProfileIndices(:,:,1)) & isnan(ProfileIndices(:,:,1))))
% sum(sum(~isnan(ProfileIndices(:,:,1)) & ~isnan(ProfileIndices(:,:,1))))

isn = isnan(Rmap)|isnan(Cmap);
linearidx = sub2ind(size(frame),Cmap(~isn),Rmap(~isn));


%% for the first image - assume the first image the bar is far from the body, near 0
% 1) calculate sigma/mu. filter a little
mu = nanmean(ProfileMat(1:round(size(ProfileMat,1)/2),:),1);
filtered_mu = smooth(mu,30);

tempf = figure; hold on; 
ax1 = subplot(2,1,1); hold on; 
plot(filtered_mu); 

ax2 = subplot(2,1,2); hold on; 
plot(evalpnts_x,filtered_mu); 

% 2) Find the best guess for the bar location: peak of the mean near evalpnts_x = 0;
[pks,locs] = findpeaks(filtered_mu,'MinPeakWidth',length(-filtered_mu)/50); %/30);
[~,loc] = min(abs(evalpnts_x(locs)));
bar_idx_i = locs(loc);
zro = evalpnts_x(bar_idx_i);
pk = pks(loc);

plot(ax1,locs,pks,'ro'); 
plot(ax1,locs(loc),pks(loc),'b+'); 
plot(ax2,evalpnts_x(locs),pks,'ro'); 
plot(ax2,evalpnts_x(locs(loc)),pks(loc),'b+'); 


% 3) Find the location of the darkest spot to the left of the bar
dark = mean(mu(mu<quantile(mu(:),0.12)));
% where the bar dips below dark
left_trough = find(flipud(filtered_mu(1:bar_idx_i))<dark,1,'first');
trough = bar_idx_i-left_trough;
% where the bar comes back over dark on the far side (in case there is
% a bright spot in the corner
left_trough = find(flipud(filtered_mu(1:trough))>dark*1.1,1,'first');
if ~isempty(left_trough)
    trough = trough-left_trough;
end
trough = max([trough 1]);

% look for the width of the bar over the trough;
barsig_win = trough:bar_idx_i;
bar_sigma = abs(evalpnts_x(find(filtered_mu(barsig_win)>.7*pk,1,'first')+trough)-zro);
threesigma = 1:length(evalpnts)>trough & evalpnts_x-zro<=1*bar_sigma;

plot(ax1,[trough trough],[0 pk],'color',[.8 .8 .8])
plot(ax2,evalpnts_x(trough)*[1 1],[0 pk],'color',[.8 .8 .8])

% 4) fit a gaussian to this part of the curve. 
% Use the left hand side, and a bit of the right hand side.
x = evalpnts_x(threesigma);

% coef = nlinfit(evalpnts_x(threesigma)',filtered_mu(threesigma)-dark,@doubleGaussian_bar_1at0,coef);
coef = nlinfit(evalpnts_x(threesigma),mu(threesigma)-dark,@gaussian_1at0,[pk,zro,bar_sigma]);
y = gaussian_1at0(coef,x);
x_right = evalpnts_x(evalpnts_x>coef(2));
y_right = gaussian_1at0(coef,x_right);

plot(ax1,find(threesigma),y,'color',[0 .8 0])
plot(ax1,find(evalpnts_x>coef(2)),y_right,'color',[0.8500    0.3250    0.0980])
plot(ax2,x,y,'color',[0 .8 0])
plot(ax2,x_right,y_right,'color',[0.8500    0.3250    0.0980])

% 4) find where the gaussian is near 0 to the right
lefthash = find(y_right < 1E-2*coef(1) ,1,'first')+sum(evalpnts_x<=coef(2));
% compare that hash to the location of the minimum between the peak and the
% right hand side
if filtered_mu(lefthash)>coef(1)+dark  % right side of the bar comes up too much
    % use the trough after peak of the model, instead
    [~,righttrough] = min(filtered_mu(bar_idx_i+1:lefthash));
    lefthash = righttrough+bar_idx_i;
    bar_threshold_right = 4/5;%
    bar_threshold_left = 1/2;%
    fprintf('\t\tWeight the left side of bar\n');
else
    bar_threshold_right = 3/5;%
    bar_threshold_left = 3/5;%
    fprintf('\t\tWeight the left and right of bar equally\n');
end

plot(ax1,lefthash*[1 1],[0 pk],'color',[1 .5 .5],'linewidth',3)
plot(ax2,evalpnts_x(lefthash)*[1 1],[0 pk],'color',[1 .5 .5],'linewidth',3)

% 5) delineate that region as empty space
% 6) find where the intensity picks up again to the right
righthash = find((filtered_mu(lefthash+1:end)-dark)>1*dark,1,'first');
righthash = righthash+lefthash;

% This might be very close to "darkness" if there is no body, so if it is
% at "left hash", make it a little to the right of left hash.
% at most it should be about 80% of the full line, bar will definitely not
% be over there

righthash = max([righthash round(0.80*size(evalpnts_x,2))]);

plot(ax1,[righthash righthash],[0 pk],'color',[.5 .5 1],'linewidth',3)
plot(ax2,evalpnts_x(righthash)*[1 1],[0 pk],'color',[.5 .5 1],'linewidth',3)
ylim(ax1,[-filtered_mu(righthash)/8 filtered_mu(righthash)])
ylim(ax2,[-filtered_mu(righthash)/8 filtered_mu(righthash)])

% 7) this is the region where the background is

% 8) get this region of the smooshed frame as the background, subtract off
% the point at left hash

mask = ~isnan(BackgroundProfiles);
mask(:,evalpnts_x<evalpnts_x(lefthash)) = 0;
Background = (BackgroundProfiles-filtered_mu(lefthash)).*mask;

ProfileMat_BS = ProfileMat-Background;
filtered_frame_mu = nanmean(ProfileMat_BS,1);
filtered_frame_mu = smooth(filtered_frame_mu,30);
% taper both ends
mb = polyfit((50:100)',filtered_frame_mu(50:100),1);
filtered_frame_mu(1:49) = mb(2)+mb(1)*(1:49);
mb = polyfit((length(evalpnts_x)-100:length(evalpnts_x)-50)',filtered_frame_mu(length(evalpnts_x)-100:length(evalpnts_x)-50),1);
filtered_frame_mu(end-49+1:end) = mb(2)+mb(1)*(length(evalpnts_x)-(49:-1:1));

[pk,loc] = max(filtered_frame_mu(trough:righthash)-dark);
loc = loc+trough;
% 9) Assume the shape of the bar doesn't change and get the CoM of the
% fullwidth @ 67% max, hopefully this will eliminate the weird jumping of
% the bar
left = find(filtered_frame_mu(1:loc)-dark<pk*bar_threshold_left,1,'last');
right = find(filtered_frame_mu(loc:end)-dark<pk*bar_threshold_right,1,'first')+loc;
% if abs(evalpnts_x(loc)-coef(2))>200 || isempty(left)
%     fprintf('Bar profile average is high on the left\n')
%     newone = find(filtered_frame_mu(1:righthash)-dark<coef(1)*bar_threshold_left*.95,1,'first');
%     [pk,loc] = max(filtered_frame_mu(newone:righthash)-dark);
%     loc = loc+newone;
%     left = find(filtered_frame_mu(newone:loc)-dark<pk*bar_threshold_left,1,'last')+newone;
%     right = find(filtered_frame_mu(loc:end)-dark<pk*bar_threshold_right,1,'first')+loc;
% end


% there is a weird case where the bar is too close to the body and the
% intensity doesn't come back down. 

% A lot of issues revolve around the bar being in the wrong place

% Another weird case is when the bath LED is in the frame! then there is a
% large amount of variation, and the trough and dark are in the wrong place

% another issue is when the bar is just slightly out of focus, then the
% variation is pretty hi and those points are the dark and trough.

% another issue is if the intensity does not come down enough between the
% bar and the body, then there is no clear place to put the left hash

r_idx = left+1:right-1;
com = round(sum(r_idx'.*filtered_frame_mu(r_idx))./sum(filtered_frame_mu(r_idx)));

bar_loc = evalpnts(:,com);
bar_loc_ontangent = evalpnts_x(com);
 
plot(ax1,left*[1 1],[0 filtered_frame_mu(left)],'color',[.7 .7 .7])
plot(ax1,right*[1 1],[0 filtered_frame_mu(right)],'color',[.7 .7 .7])
plot(ax1,com*[1 1],[0 filtered_frame_mu(com)],'color',[0 0 0],'linewidth',3)
plot(ax2,evalpnts_x(left)*[1 1],[0 filtered_frame_mu(left)],'color',[.7 .7 .7])
plot(ax2,evalpnts_x(right)*[1 1],[0 filtered_frame_mu(right)],'color',[.7 .7 .7])
plot(ax2,evalpnts_x(com)*[1 1],[0 filtered_frame_mu(com)],'color',[0 0 0],'linewidth',3)

close(tempf)
%%
profileFigure = findobj('type','figure','tag','profile_fig');
if isempty(profileFigure)
    profileFigure = figure;
    profileFigure.Position = [1331 421 560 420];
    profileFigure.Tag = 'profile_fig';    
end
profileAxes = subplot(1,1,1,'parent',profileFigure); cla(profileAxes); hold(profileAxes,'on');
% plot(evalpnts_x,filtered_sigma_mu/max(filtered_sigma_mu)*max(filtered_mu),'g','parent',profileAxes);
plot(evalpnts_x,filtered_mu,'color',[0 .7 0],'parent',profileAxes);
plot(evalpnts_x(locs),pks,'markeredgecolor',[1 1 1]*.8,'marker','o','linestyle','none','parent',profileAxes);
plot(zro,pk+dark,'markeredgecolor',[1 1 1]*0,'markerfacecolor',[1 1 1]*0,'marker','o','linestyle','none','parent',profileAxes);

plot(evalpnts_x(evalpnts_x>zro-3*coef(3)),gaussian_1at0(coef,evalpnts_x(evalpnts_x>zro-3*coef(3))),'color',[0 0 1],'parent',profileAxes);
% plot(evalpnts_x(lefthash),0,'markeredgecolor',[1 0 0],'marker','o','linestyle','none','parent',profileAxes);
plot([evalpnts_x(lefthash) evalpnts_x(lefthash)],[0 max(filtered_mu)],'color',[1.2 1 1]*.8,'parent',profileAxes);
plot([evalpnts_x(righthash) evalpnts_x(righthash)],[0 max(filtered_mu)],'color',[1 1 1.2]*.8,'parent',profileAxes);

profmu = plot(evalpnts_x,filtered_frame_mu,'color',[0 0 0],'parent',profileAxes);
bar_ontangent = plot([evalpnts_x(com),evalpnts_x(com)],[0 max(filtered_mu)],'color',[0 0 0],'parent',profileAxes);
rocom_left = plot(evalpnts_x(left)*[1 1],[0 filtered_frame_mu(left)],'color',[0 0 0],'parent',profileAxes);
rocom_right = plot(evalpnts_x(right)*[1 1],[0 filtered_frame_mu(right)],'color',[0 0 0],'parent',profileAxes);

displayf = findobj('type','figure','tag','big_fig');
if isempty(displayf)
    displayf = figure;
    displayf.Position = [40 2 640 530];
    displayf.Tag = 'big_fig';
end
dispax = findobj(displayf,'type','axes','tag','dispax');
if isempty(dispax) 
    dispax = axes('parent',displayf,'units','pixels','position',[0 0 640 512],'tag','dispax');
    dispax.Box = 'off'; dispax.XTick = []; dispax.YTick = []; dispax.Tag = 'dispax';
    colormap(dispax,'gray')
end
hold(dispax,'off')
im = imshow(frame,[0 2*quantile(frame(:),0.975)],'parent',dispax);
hold(dispax,'on');
% find limits projected along x
line(trial.forceProbe_line(:,1),trial.forceProbe_line(:,2),'parent',dispax,'color',[1 0 0]);
% line(p_(1),p_(2),'parent',dispax,'marker','o','markeredgecolor',[0 1 1]);
line(l_r(:,1),l_r(:,2),'parent',dispax,'color',[1 .3 .3]);
%line(moveEvalPntsAlong(1,1),moveEvalPntsAlong(2,1),'parent',dispax,'marker','o','markeredgecolor',[0 0 1],'markerfacecolor',[1 1 1]);
bar_spot = line(moveEvalPntsAlong(1,1)+bar_loc(1),moveEvalPntsAlong(2,1)+bar_loc(2),'parent',dispax,'marker','o','markeredgecolor',[0 0 1],'markerfacecolor',[1 1 1]);


displayf2 = findobj('type','figure','tag','big_fig2');
if isempty(displayf2)
    displayf2 = figure;
    displayf2.Position = [640 100 size(ProfileMat_BS,2)/2 3.1*size(ProfileMat_BS,1)/2];
    displayf2.Tag = 'big_fig2';
end
delete(findobj(displayf2,'type','axes'));

dispax1 = axes('parent',displayf2,'units','pixels','position',[0 2*size(ProfileMat_BS,1)/2 size(ProfileMat_BS,2)/2 size(ProfileMat_BS,1)/2]);
dispax2 = axes('parent',displayf2,'units','pixels','position',[0 1*size(ProfileMat_BS,1)/2 size(ProfileMat_BS,2)/2 size(ProfileMat_BS,1)/2]);
dispax3 = axes('parent',displayf2,'units','pixels','position',[0 0*size(ProfileMat_BS,1)/2 size(ProfileMat_BS,2)/2 size(ProfileMat_BS,1)/2]);
% set(dispax2,'box','off','xtick',[],'ytick',[],'tag','dispax');
colormap(dispax2,'gray')

pm = imshow(ProfileMat,[0 2*quantile(Background(:),0.975)],'parent',dispax1);
bk = imshow(Background,[0 2*quantile(Background(:),0.975)],'parent',dispax2);
lr = line([lefthash,lefthash],[1 size(Background,1)],'parent',dispax2,'color',[1 .5 .5]);
pm_bs = imshow(ProfileMat_BS,[0 2*quantile(ProfileMat_BS(:),0.975)],'parent',dispax3);
rr = line([righthash,righthash],[1 size(ProfileMat_BS,1)],'parent',dispax3,'color',[.5 .5 1]);
bar = line([loc,loc],[1 size(ProfileMat_BS,1)],'parent',dispax3,'color',[1 0 1]);

trial.forceProbeStuff.line = trial.forceProbe_line;
trial.forceProbeStuff.tangent = trial.forceProbe_tangent;
trial.forceProbeStuff.barmodel = coef;
% h.forceProbeStuff.TransformMap = cat(3,Cmap,Rmap);
% h.forceProbeStuff.Background = Background;
% h.forceProbeStuff.lefthash = Background;
trial.forceProbeStuff.EvalPnts = evalpnts;
trial.forceProbeStuff.EvalPnts_x = evalpnts_x;
trial.forceProbeStuff.EvalPnts_y = moveEvalPntsAlong;
% trial.forceProbeStuff.Origin = moveEvalPntsAlong(:,1); % This is a
% useless addition. This version of Origin was just the xy position of the
% y values.


%%

% go through the movie
% 1) substract off the background region
% 2) find the peak of the mean trace. That's where the bar is

% figure(displayf)
% figure(displayf2)
figure(profileFigure)


% look for movie file

% import movie
vid = VideoReader(trial.imageFile);
N = round(vid.Duration*vid.FrameRate);
h2 = postHocExposureRaw(trial,N);
t = makeInTime(trial.params);

kk = 0;

% find the first frame  for calcium imaging
% k0 = find(t(h2.exposure)>0,2,'first');
% k0 = k0(end);

% find the first frame for IR illumination
k0 = 1;

% find the last frame
% kf = find(t(h2.exposure)<h.params.stimDurInSec,1,'last');
kf = find(t(h2.exposure)<trial.params.durSweep,1,'last');

br_trial = waitbar(0,sprintf('%d',kk));
br_trial.Name = 'Frames';

forceProbePosition = nan(2,N);
CoM = nan(1,N);
keimograph = nan(length(evalpnts_x),N);

while hasFrame(vid)
    kk = kk+1;
    waitbar(kk/N,br_trial,sprintf('%d',kk));

    if kk<k0
        readFrame(vid);
        continue
    elseif kk>kf
        break
    end
%     tic
    mov3 = readFrame(vid);
    frame = mov3;
%     fprintf('Load: '),toc
    tic
    if exist('annulusvals','var')
        annulusvals = frame(annulusmask&~spotmask);
        I = mean(annulusvals);
        frame(spotmask) = I;
    end

    ProfileMat(:) = nan;
    ProfileMat(~isn) = frame(linearidx); % *** Nice addition, so much faster than before! ***;
    
    ProfileMat_BS = ProfileMat-Background;
    filtered_frame_mu = nanmean(ProfileMat_BS,1);
    filtered_frame_mu = smooth(filtered_frame_mu,30);
    
    % taper both ends
    mb = polyfit((50:100)',filtered_frame_mu(50:100),1);
    filtered_frame_mu(1:49) = mb(2)+mb(1)*(1:49);
    mb = polyfit((length(evalpnts_x)-100:length(evalpnts_x)-50)',filtered_frame_mu(length(evalpnts_x)-100:length(evalpnts_x)-50),1);
    filtered_frame_mu(end-49+1:end) = mb(2)+mb(1)*(length(evalpnts_x)-(49:-1:1));
    
    % find the dark values
    dark = mean(filtered_frame_mu(filtered_frame_mu<quantile(filtered_frame_mu(:),0.12)));
    
    loc_old = loc;
    left_old = left;
    right_old = right;
    
    if filtered_frame_mu(righthash) < filtered_frame_mu(trough)
        [pk,loc] = max(filtered_frame_mu(trough:righthash)-dark);
        loc = loc+trough;
    else
        [pk,loc] = max(filtered_frame_mu(trough:lefthash)-dark);
        loc = loc+trough;
    end

    % 9) Assume the shape of the bar doesn't change and get the CoM of the
    % fullwidth @ 67% max, hopefully this will eliminate the weird jumping of
    % the bar
    left = find(filtered_frame_mu(1:loc)-dark<pk*bar_threshold_left,1,'last');
    right = find(filtered_frame_mu(loc:end)-dark<pk*bar_threshold_right,1,'first')+loc;
    
    if (~isempty(left) && ~isempty(left_old) && left<.6*left_old)...
        || (~isempty(right) && ~isempty(right_old) && right<.6*right_old)...
        || loc<.6*loc_old
        [pk,loc] = max(filtered_frame_mu(round(.6*loc_old):righthash)-dark);
        loc = loc+round(.6*loc_old);
        
        left = find(filtered_frame_mu(round(.6*loc_old):loc)-dark<pk*bar_threshold_left,1,'last'); 
        left = left+round(.6*loc_old);
        right = find(filtered_frame_mu(loc:end)-dark<pk*bar_threshold_right,1,'first')+loc;
       
    end
    profmu.YData = filtered_frame_mu;

    if isempty(left) || isempty(right)
        continue
    end
    rocom_left.XData = evalpnts_x(left) *[1 1];
    rocom_left.YData = [0 filtered_frame_mu(left)];
    rocom_right.XData = evalpnts_x(right) *[1 1];
    rocom_right.YData = [0 filtered_frame_mu(right)];

    
    r_idx = left+1:right-1;
    com = sum(r_idx'.*filtered_frame_mu(r_idx))./sum(filtered_frame_mu(r_idx));
        
    origin = find(evalpnts(1,:)==0&evalpnts(2,:)==0);
    x_hat = evalpnts(:,origin+1);
    forceProbePosition(:,kk) = x_hat.*(com-origin);

    keimograph(:,kk) = filtered_frame_mu;
    CoM(kk) = com;
    
    %     bar_loc = evalpnts(:,com);
    %     forceProbePosition(:,kk) = bar_loc;
    
%     im.CData = frame;
%     bar.XData = [loc loc];
%     pm_bs.CData = ProfileMat_BS;
%     bar_spot.XData = moveEvalPntsAlong(1,1)+bar_loc(1);
%     bar_spot.YData = moveEvalPntsAlong(2,1)+bar_loc(2);

    bar_ontangent.XData = [com+evalpnts_x(1) com+evalpnts_x(1)];
    
    drawnow
%     fprintf('CoM : '),toc
end
delete(br_trial);
    
trial.forceProbeStuff.forceProbePosition = forceProbePosition;
trial.forceProbeStuff.CoM = CoM;
fprintf('Saving bar position\n')
save(trial.name,'-struct','trial')

save(regexprep(trial.name,'_Raw_','_keimograph_'),'keimograph');

% close(displayf)
% close(displayf2)
close(profileFigure)

