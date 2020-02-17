figure

[ax]=tight_subplot(6,4,[.03 .02],[.08 .08],[.09 0.03]);
fig_ind = 1;
for pos = 1:4
    for ld = 1
        for ch = 1:6
            axes(ax(fig_ind));
            hold all
            
        end
    end
end

%%
figure
c = colormap(lines);
win = .5;
Fs = 1000;
[ax] = tight_subplot(6,4,[.03 0],[.08 .08],[.09 0.03]);
fig_ind = 1;
for pos = 1:4
    for ld = 1
        for dof = 1
%             for i = 1:length(data.off.ind)
                temp_ind = find(data.off.dof == dof & data.off.arm == pos);
                mid = temp_ind(50);
                for ch = 1:6
                    temp_fig = fig_ind + (ch-1)*4;
                    axes(ax(temp_fig));
                    hold all
                    temp = data.daq.DAQ_DATA(data.off.ind(mid):data.off.ind(mid)+win*Fs-1,ch);
                    t = 1:win*Fs;
                    plot(t,temp,'color',c(ch,:))
                    maxemg = max(max(data.daq.DAQ_DATA(data.off.ind(temp_ind),:)));
                    ylim([-maxemg maxemg])
                    set(gca,'XTick',[])
                    set(gca,'XTickLabels',[])
                    if pos > 1
                        set(gca,'YTick',[])
                    end
                end
                
%             end
        end
    end
    fig_ind = fig_ind+1;
end