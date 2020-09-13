
%==================Input=====================
%Specify the name of the folder that contains the data/list
%Specify the name of file that contains the reference stars
%Specify the center of FoV
%For now, only the RA Dec info will be used, so specify locations of RA Dec
%in the data/list


Folder      =   'MEDIAN_coadded_5m';
FITS        =   'TiDO*';
filename    =   dir(fullfile(Folder,FITS));
ref_file    =   'ref_V_TiDO_154.3853+10.5785.cat';
center      =   [154.3853,10.5785];
X_posi      =   1;
Y_posi      =   2;
RA          =   12;
DEC         =   13;
Mag         =   17;
delimiterIn = ' ';
headerlinesIn = 37;


%================End of Input=================


LIST        =   [];

%Boundary Selection
RAup        =   center(1)+3*2;
RAdown      =   center(1)-3*2;
Decup       =   center(2)+2*2;
Decdown     =   center(2)-3*2;

R = linspace(RAdown,RAup,7);
D = linspace(Decdown,Decup,6);

ref_LIST = importdata(ref_file);ref_LIST = ref_LIST(:,1:3);

sequence = linspace(1,180,180);

T1=clock;
for i=sequence
    
    t1=clock;
    
    catalogname = filename(i).name;
    A = importdata(fullfile(filename(i).folder,catalogname),delimiterIn,headerlinesIn);
    if size(A,1) ~= 0
        A = A.data;
    else
        continue;
    end
    new_list = [];
    if size(A,1) ~= 0
        A = [A(:,RA),A(:,DEC),A(:,Mag)];
        for k = 1:7
            for j = 1:6

                region_Center = [R(k),D(j),0];
                B = ismembertol(ref_LIST,region_Center,1,'ByRows',true,'DataScale',[1,1,inf]);
                B = ref_LIST(logical(B),:);                
                ref_Star = B;
                ref_Star = uniquetol(ref_Star,0.05,'ByRows',true,'DataScale',[1,1,inf]);

                tmp = ismembertol(A,region_Center,1,'ByRows',true,'DataScale',[1,1,inf]);
                tmp_list = A(logical(tmp),:);

                [ind,loc] = ismembertol(tmp_list,ref_Star,0.01,'ByRows',true,'DataScale',[1,1,inf]);
                ref = tmp_list(logical(ind),:);
                loc(loc == 0)=[];
                ref_s = ref_Star(loc,:);
                dRA = mean(ref(:,1) - ref_s(:,1));
                dDec = mean(ref(:,2) - ref_s(:,2));
                dMag = mean(ref(:,3) - ref_s(:,3));
                
                Corrected_list = zeros(length(tmp_list),3);
                Corrected_list(:,1) = tmp_list(:,1) - dRA;
                Corrected_list(:,2) = tmp_list(:,2) - dDec;
                Corrected_list(:,3) = tmp_list(:,3) - dMag;
                new_list = [new_list;Corrected_list];                


            end
        end
    end

    Index =  ismembertol(new_list, ref_LIST, 0.004,'ByRows',true,'DataScale',[15,1,inf]);
    Count = sum(Index);
    %display(strcat(num2str(Count),' ref stars have been fitted'));
    Index = Index + 1;
    Index(Index == 2) = 0;
    Corrected_list = new_list(logical(Index),:);
    LIST = [LIST;Corrected_list];  
    if i == 1
        t2=clock;
        disp(strcat(num2str(length(sequence)),' lists to be combined, ',num2str(etime(t2,t1)/60*length(sequence)),' minutes expected.'))
    end
end
T2 = clock;

disp(strcat('Lists calibration and combination finished, running time ',num2str(etime(T2,T1)/60),' minutes in total.'));

disp('Start searching tracklets now...');
save Combined_starlist.txt -ascii LIST;

% figure;
% scatter(LIST(:,1),LIST(:,2),'.');
%hold on; scatter(ref_LIST(:,1),ref_LIST(:,2),'r.');
%scatter(new_list(:,1),new_list(:,2),'.')
detected_center = [];
sample_subfield;




