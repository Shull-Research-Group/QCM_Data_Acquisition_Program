%This script will correct the timepoints for files that were obtained from
%version 2.0b and below
function correct_timepoints(filename,save_flag)
disp('Loading files');
shifts=load(filename);
spectras=load([filename(1:end-4),'_raw_spectras.mat']);
spectra_names=fieldnames(spectras);
rm1=find(strcmp(spectra_names,'reference')==1);         rm2=find(strcmp(spectra_names,'version')==1);
spectra_names([rm1,rm2])=[];
[pathstr,base_name,~] = fileparts(filename);
index=length(base_name)+4;
disp('Correction in process...please wait');
for dum=1:size(spectra_names,1)
    temp=spectra_names{dum};
    spectra_names{dum,2}=temp(index:end-10);%in min
    spectra_names{dum,3}=str2double(strrep(temp(index:end-10),'dot','.'));%in min
end
spectra_time=cell2mat(spectra_names(:,3));
[spectra_time,I]=sort(spectra_time);
spectra_names=spectra_names(I,:);
ref_time=datevec(shifts.reference(1,:),'yy:mm:dd:HH:MM:SS:FFF');
[set_date_labels,set_date]=time_correct01(ref_time);
%find corresponding correction
wrong=cell2mat(set_date(:,3));
difference=cell2mat(set_date(:,5));
index1=find(difference==0);
temp=wrong-max(spectra_time);
index2=find(temp<=0,1,'last');
indices3=index1:1:index2;
spectra_time_corr=[];
for dum=1:length(indices3)
    lb=set_date{indices3(dum),3};
    ub=set_date{indices3(dum)+1,4};
    indices4=find(spectra_time>=lb&spectra_time<ub);
    spectra_time_corr=[spectra_time_corr;spectra_time(indices4)-set_date{indices3(dum),5}];
end;    disp('Correction in process...please wait');
for dum=1:size(spectra_names,1)    
    if mod(dum,600)==0;     disp(['Corrected ',num2str(dum),' files...']);     end;
    spectra_names{dum,4}=spectra_time_corr(dum);
    spectra_names{dum,5}=strrep(num2str(spectra_time_corr(dum)),'.','dot');
    spectra_names{dum,6}=strrep(spectra_names{dum,1},spectra_names{dum,2},spectra_names{dum,5});
    spectras_corr.(spectra_names{dum,6})=spectras.(spectra_names{dum,1});
    index5=find(shifts.abs_freq==spectra_names{dum,3});
    shifts.abs_freq(index5,1)=spectra_time_corr(dum);
end
shifts.chisq_values(:,1)=shifts.abs_freq(:,1);
shifts.freq_shift(:,1)=shifts.abs_freq(:,1);
disp('Finishing up process...');
if save_flag==0
    assignin('base','shifts',shifts);
    assignin('base','spectras_corr',spectras_corr);
    assignin('base','spectra_names',spectra_names);
else
%     save corrections
    base_name_corr=[base_name,'_tcorr'];
    save([pathstr,'/',base_name_corr,'.mat'],'-struct','shifts');
    save([pathstr,'/',base_name_corr,'_raw_spectras.mat'],'-struct','spectras_corr');
end;    disp('Correction complete!');


function [set_date_labels,set_date]=time_correct01(ref_time)
%set_date col format: set_date, ref_date, wrong, correct, difference
set_date=cell(1e4,6);
count=1;
% ref_time=[15,4,30,0,0,0];
for yy=2013:2015
    for mm=1:12
        if mm==1||mm==3||mm==5||mm==7||mm==8||mm==10||mm==12
            for dd=1
                set_date{count,1}=[yy,mm,dd,00,00,00.000];
                set_date{count,2}=ref_time;
                Z=[yy,mm,dd,00,00,00.000]-ref_time;
                set_date{count,3}=Z(1)*525960+Z(2)*43830+Z(3)*1440+Z(4)*60+Z(5)+Z(6)./60;
                set_date{count,4}=etime([yy,mm,dd,00,00,00.000],ref_time)/60;
                set_date{count,5}=(Z(1)*525960+Z(2)*43830+Z(3)*1440+Z(4)*60+Z(5)+Z(6)./60)-etime([yy,mm,dd,00,00,00.000],ref_time)/60;
                if count==1
                    set_date{count,6}=set_date{count,5};
                else
                    set_date{count,6}=set_date{count-1,5}+set_date{count,5};
                end
                count=count+1;
            end
        else
            for dd=1
                set_date{count,1}=[yy,mm,dd,00,00,00.000];
                set_date{count,2}=ref_time;
                Z=[yy,mm,dd,00,00,00.000]-ref_time;
                set_date{count,3}=Z(1)*525960+Z(2)*43830+Z(3)*1440+Z(4)*60+Z(5)+Z(6)./60;
                set_date{count,4}=etime([yy,mm,dd,00,00,00.000],ref_time)/60;
                set_date{count,5}=(Z(1)*525960+Z(2)*43830+Z(3)*1440+Z(4)*60+Z(5)+Z(6)./60)-etime([yy,mm,dd,00,00,00.000],ref_time)/60;
                if count==1
                    set_date{count,6}=set_date{count,5};
                else
                    set_date{count,6}=set_date{count-1,5}+set_date{count,5};
                end
                count=count+1;
            end
        end
    end
end
set_date_labels=[{'set date times'},{'ref date time'},{'wrong (min)'},{'correct (min)'},{'wrong-correct'},{'cumsum(wrong-correct)'}];
% disp('complete');