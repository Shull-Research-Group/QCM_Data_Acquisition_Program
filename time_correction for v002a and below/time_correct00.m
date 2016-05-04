function [set_date_labels,set_date]=time_correct00(ref_time)
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