function hfig = plot_mean_sem(x,data,color)

avg = mean(data,"omitnan");
% sem = std(data,"omitnan")/sqrt(size(data,1));
sem = std(data,"omitnan")./sqrt(sum(~isnan(data)));
nanFixAvg = avg;
nanFixAvg(isnan(nanFixAvg)) = 0;
nanFixSem = sem;
nanFixSem(isnan(sem)) = 1000;
nanFixSem(isinf(sem)) = 1000;
hold on
patch([x fliplr(x)], [nanFixAvg-nanFixSem, fliplr(nanFixAvg+nanFixSem)],color,"FaceAlpha",0.2,"EdgeColor","none")
plot(x,avg,"Color",color*0.7,"LineWidth",2)
% xlim([x(1) x(end)])
hold off

end