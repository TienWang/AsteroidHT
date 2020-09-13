subR = linspace(RAdown,RAup,12/0.25+1);
subD = linspace(Decdown,Decup,10/0.15+1);

for i = 1:length(subR)
    tic;
    for j = 1:length(subD)
        sub_center = [subR(i),subD(j),0];
        tmp = ismembertol(LIST,sub_center,1,'ByRows',true,'DataScale',[0.25,0.15,inf]);
        tmp = LIST(logical(tmp),:);
        img = scatter(tmp(:,1),tmp(:,2),'.');hold on;axis off;saveas(img,'tmp.png');close();
        HoughTransform;
    end
    toc;
    count = i*length(subD);
    disp(strcat(num2str(count),' out of ',num2str(length(subR)*length(subD)),' subfields have been done!'))
end