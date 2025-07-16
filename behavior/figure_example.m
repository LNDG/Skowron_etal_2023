% figure example inference
%clear all

% narrow prior
Nblue = [4 1 4 1 6];
Nred = [1 0 1 0 3];

alpha=10;
beta=10;

beta_sam = linspace(0,1,200);

% uncertainty trajectories (wide, narrow)
sd_traj = nan(2,length(Nblue));

for i = 1:length(Nblue)
    
    y=betapdf(beta_sam,alpha,beta);
    
    if i == 1
        subplot(1,3,1)
        h=plot(beta_sam,y,'r-','LineWidth',5)
        ylabel('probability density')
        set(h, 'Color', '#82099c')
        set(gca,'FontSize',32)
        xticks(0:0.5:1)
        yticks([])
        hold on
        
    elseif i == 2
        subplot(1,3,2)
        h=plot(beta_sam,y,'r-','LineWidth',5)
        xlabel('proportion blue')
        set(h, 'Color', '#82099c')
        set(gca,'FontSize',32)
        xticks(0:0.5:1)
        yticks([])
        hold on
        
    elseif i == 5
        subplot(1,3,3)
        h=plot(beta_sam,y,'r-','LineWidth',5)
        set(h, 'Color', '#82099c')
        set(gca,'FontSize',32)
        xticks(0:0.5:1)
        yticks([])
        hold on
        
    end
    
    alpha=alpha+Nblue(i);
    beta=beta+Nred(i);
    
    sd_traj(1,i)=(alpha*beta)/((alpha+beta)^2*(alpha+beta+1));
    
end

%saveas(gcf,'narrow_prior_example.jpg')

% wide observer
Nblue = [4 1 4 1 6];
Nred = [1 0 1 0 3];

alpha=2;
beta=2;

beta_sam = linspace(0,1,200);

for i = 1:length(Nblue)
    
    y=betapdf(beta_sam,alpha,beta);
    
    if i == 1
        subplot(1,3,1)
        h=plot(beta_sam,y,'b-','LineWidth',5)
        ylabel('probability density')
        set(h, 'Color', '#f8860e')
        set(gca,'FontSize',32)
        xticks(0:0.5:1)
        yticks([])
        
    elseif i == 2
        subplot(1,3,2)
        h=plot(beta_sam,y,'b-','LineWidth',5)
        xlabel('proportion blue')
        set(h, 'Color', '#f8860e')
        set(gca,'FontSize',32)
        xticks(0:0.5:1)
        yticks([])
        
    elseif i == 5
        subplot(1,3,3)
        h=plot(beta_sam,y,'b-','LineWidth',5)
        set(h, 'Color', '#f8860e')
        set(gca,'FontSize',32)
        xticks(0:0.5:1)
        yticks([])
        
    end
    
    alpha=alpha+Nblue(i);
    beta=beta+Nred(i);
    
    sd_traj(2,i)=(alpha*beta)/((alpha+beta)^2*(alpha+beta+1));
    
end

% saveas(gcf,'ideal_narrow_example.svg')
% close all

%% plot sd traj

h=plot(1:size(sd_traj,2),sd_traj(1,:),'square','LineWidth',1)
set(h, 'Color', '#82099c')
set(h, 'MarkerSize', 20)
set(h, 'MarkerFaceColor', '#82099c')
hold on

h=plot(1:size(sd_traj,2),sd_traj(1,:),'-','LineWidth',5)
set(h, 'Color', '#82099c')

h=plot(1:size(sd_traj,2),sd_traj(2,:),'square','LineWidth',1)
set(h, 'Color', '#f8860e')
set(h, 'MarkerSize', 20)
set(h, 'MarkerFaceColor', '#f8860e')

h=plot(1:size(sd_traj,2),sd_traj(2,:),'-','LineWidth',5)
set(h, 'Color', '#f8860e')

xticks(1:length(Nblue))
set(gca,'FontSize',32)

hold off

% saveas(gcf,'sd_traj_example.svg')