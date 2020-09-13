
I=imread('tmp.png');
BW=im2bw(I);
BW = BW+1;
BW(BW==2) = 0;
%imshow(BW);
%title('原图');
%对图像进行Hough变换
[H,T,R]=hough(BW);  %[H,theta,rho]
%显示变换域
%figure,imshow(imadjust(rescale(H)),'XData',T,'YData',R,'InitialMagnification','fit');
%xlabel('\theta');ylabel('\rho');
%axis on,axis normal,hold on
%title('变换域');
%计算变换域峰值
P=houghpeaks(H,2,'threshold',ceil(0.6*max(H(:))));
x=T(P(:,2));y=R(P(:,1));
%plot(x,y,'s','color','red');
%标记直线
lines=houghlines(BW,T,R,P,'FillGap',10,'MinLength',60);
if ~isempty(lines)
    disp(strcat('Tracklets found around(',num2str(sub_center(1)),',+',num2str(sub_center(2)),')'))
    img = figure;
    imshow(BW),hold on
    saveas(img,strcat('results/img/',num2str(sub_center(1)),'_',num2str(sub_center(2)),'.png'));
    for k=1:length(lines)
        xy=[lines(k).point1;lines(k).point2];
        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','blue');
        %Plot beginning and ends of lines
        plot(xy(1,1),xy(1,2),'xw','LineWidth',2);
        plot(xy(2,1),xy(2,2),'xw','LineWidth',2);
    end
    saveas(img,strcat('results/HT_line/',num2str(sub_center(1)),'_',num2str(sub_center(2)),'.png'));
    close();
    cen_RA = degrees2hms(subcenter(1));
    cen_DE = degrees2dms(subcenter(2));
    cen = [cen_RA,cen_DE];
    detected_center = [detected_center;cen];
    save detected_center.txt -ascii detected_center
end
