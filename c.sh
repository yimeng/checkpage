#!/bin/bash
export LANG=C
TIME=`date +"%F_%T"`
LOGIN="stdjtu:xxxxx"
CHECKPATH="/home/dlgoldne/public_html/xdream/checkpage"
P="\/home\/dlgoldne\/public_html\/xdream\/checkpage\/"
#�����б�ҳ
LISTURL="http://www.stdjtu.edu.cn/main/jwzx.asp"
#�б�������
LISTKEY="news.asp?newsid=[0-9]\{4\}"
#��ȡ�����ļ�
HREFFILE="$CHECKPATH/href.awk"
#�ļ�������
FILEKEY="/admin/UploadFile/ea_[0-9]*\.[a-z]\{3\}"
#��Ŀ������
TITLEKEY='s/.*<td width="63%"><a href=\"pingjian.asp\?newsid=2026\">\(.*\)</a></td>.*/\1/ip;T;q'
#��ȡ���µĸ���ҳ
curl -s $LISTURL> $CHECKPATH/newpage.txt
txt=`cat $CHECKPATH/newpage.txt|grep 116052`
echo $txt
while [ -z "$txt" ]; do 
curl -s $LISTURL> $CHECKPATH/newpage.txt
txt=`cat newpage.txt|grep 116052`
#echo error:$txt
done


oldPAGELIST=(`cat $CHECKPATH/oldpage.txt|grep $LISTKEY|awk -f $HREFFILE`)
newPAGELIST=(`cat $CHECKPATH/newpage.txt|grep $LISTKEY|awk -f $HREFFILE`)
#echo ${#newPAGELIST[@]}
#echo ${#oldPAGELIST[@]}
#gt���� ltС��
if [ ${#newPAGELIST[@]} -gt ${#oldPAGELIST[@]} ];then
LISTLEN=${#newPAGELIST[@]}
else
LISTLEN=${#oldPAGELIST[@]}
fi
#LISTLEN=${#PAGELIST[@]}
echo $LISTLEN
CHECKDATE=`date +"%F"`
#˫ѭ��,�ж��Ƿ������ݸ���iΪ������,jΪ������
for ((i=0;i<LISTLEN;i++))
do
#echo ${oldPAGELIST[$count]} is over
	#c=0
	c=0
	for ((j=0;j<LISTLEN;j++))
	do
	#�����ݱȽϾ�����
		
#		echo ${newPAGELIST[$i]} nnnn
#		echo ${oldPAGELIST[$j]} oooo
	#����������ھ������д��ڼ���,c��������,0��Ϊ������,����0��Ϊ������
		if [ "${newPAGELIST[$i]}" = "${oldPAGELIST[$j]}" ] ; then	
		((c++))
		#echo $c jj
		#else
		#echo $c ee
		fi
	done		
			if [ $c -eq 0 ];then
				#����ʱ�佨��Ŀ¼
				if [ $LISTLEN -ne 0 ];then
					[ -d "$CHECKDATE" ] || mkdir -p $CHECKDATE
				fi
				
			t=(`sed -n "s/.*<a href=\"${newPAGELIST[$i]}\">\(.*\)<\/a><\/td>.*/\1/ip;T;q" $CHECKPATH/newpage.txt`)
			
			PAGEURL=http://www.stdjtu.edu.cn/main/${newPAGELIST[$i]}
			#FILEUUU=http://bak.stdjtu.edu.cn/${newPAGELIST[$i]}
			echo $PAGEURL
			FILEURL=`curl -s $PAGEURL|grep $FILEKEY|awk -f $HREFFILE`
			echo $FILEURL
			wget -P $CHECKDATE $FILEURL 
			echo ���ѧԺ��������� $t  ���ص�ַ:$FILEURL ������ $TIME ��⵽
			#curl -u $LOGIN -Fstatus="���ѧԺ��������� $t,���ص�ַ:$FILEURL" http://api.jiwai.de/statuses/update.json
				
				
			#else
				#if [ $c -eq 1 ];then
				#echo ${newPAGELIST[$i]}is same with ${oldPAGELIST[$j]}
				
				
				#fi
			fi
done	
cp $CHECKPATH/newpage.txt $CHECKPATH/oldpage.txt --reply=yes
