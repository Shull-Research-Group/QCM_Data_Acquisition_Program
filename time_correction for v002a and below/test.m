% % 
% % 
% % %%
% % clc
% % clear all;
% % test_ref=datevec(['15:04:30:23:59:59:999'],'yy:mm:dd:HH:MM:SS:FFF');
% % next=datevec(['15:05:01:00:00:00:000'],'yy:mm:dd:HH:MM:SS:FFF');
% % difference=ones(1e6,1);
% % count=1;
% % for MM=0:6
% %     next(2)=next(2)+MM;
% %     Z=next-test_ref;
% %     wrong=Z(1)*525960+Z(2)*43830+Z(3)*1440+Z(4)*60+Z(5)+Z(6)./60;%fix time into MINUTES
% %     correct=etime(next,test_ref)/60;
% %     difference(count)=wrong-correct;
% %     count=count+1;
% % end
% % 
% % disp('done')
% % figure(1);
% % clf(figure(1));
% % plot([0:1:6],difference(1:7),'bo','linewidth',2);
% % xlabel('days');
% % ylabel('error in min.');
% %%
% clear all;clc;
% %set_date col format: set_date, ref_date, wrong, correct, difference
% set_date=cell(1e4,5);
% count=1;
% ref_time=[15,4,30,0,0,0];
% for yy=13:15
%     for mm=1:12
%         disp(mm);
%         if mm==1||mm==3||mm==5||mm==7||mm==8||mm==10||mm==12
%             for dd=1
%                 set_date{count,1}=[yy,mm,dd,00,00,00.000];
%                 set_date{count,2}=ref_time;
%                 Z=[yy,mm,dd,00,00,00.000]-ref_time;
%                 set_date{count,3}=Z(1)*525960+Z(2)*43830+Z(3)*1440+Z(4)*60+Z(5)+Z(6)./60;
%                 set_date{count,4}=etime([yy,mm,dd,00,00,00.000],ref_time)/60;
%                 set_date{count,5}=(Z(1)*525960+Z(2)*43830+Z(3)*1440+Z(4)*60+Z(5)+Z(6)./60)-etime([yy,mm,dd,00,00,00.000],ref_time)/60;
%                 count=count+1;
%             end
%         else
%             for dd=1
%                 set_date{count,1}=[yy,mm,dd,00,00,00.000];
%                 set_date{count,2}=ref_time;
%                 Z=[yy,mm,dd,00,00,00.000]-ref_time;
%                 set_date{count,3}=Z(1)*525960+Z(2)*43830+Z(3)*1440+Z(4)*60+Z(5)+Z(6)./60;
%                 set_date{count,4}=etime([yy,mm,dd,00,00,00.000],ref_time)/60;
%                 set_date{count,5}=(Z(1)*525960+Z(2)*43830+Z(3)*1440+Z(4)*60+Z(5)+Z(6)./60)-etime([yy,mm,dd,00,00,00.000],ref_time)/60;
%                 count=count+1;
%             end
%         end
%     end
% end
% set_date_labels=[{'set date times'},{'ref date time'},{'wrong (min)'},{'correct (min)'},{'wrong-correct'}];
% disp('complete');

filename='C:\Users\Josh\Dropbox\Northwestern University\My Research\Data\Rush\cell_media_37C_043015.mat';
correct_timepoints(filename,0);