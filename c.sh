#!/bin/bash
export LANG=C
TIME=`date +"%F_%T"`
LOGIN="stdjtu:xxxxx"
CHECKPATH="/home/dlgoldne/public_html/xdream/checkpage"
P="\/home\/dlgoldne\/public_html\/xdream\/checkpage\/"
#更新列表页
LISTURL="http://www.stdjtu.edu.cn/main/jwzx.asp"
#列表特征码
LISTKEY="news.asp?newsid=[0-9]\{4\}"
#提取链接文件
HREFFILE="$CHECKPATH/href.awk"
#文件特征码
FILEKEY="/admin/UploadFile/ea_[0-9]*\.[a-z]\{3\}"
#题目特征码
TITLEKEY='s/.*<td width="63%"><a href=\"pingjian.asp\?newsid=2026\">\(.*\)</a></td>.*/\1/ip;T;q'
#获取最新的更新页
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
#gt大于 lt小于
if [ ${#newPAGELIST[@]} -gt ${#oldPAGELIST[@]} ];then
LISTLEN=${#newPAGELIST[@]}
else
LISTLEN=${#oldPAGELIST[@]}
fi
#LISTLEN=${#PAGELIST[@]}
echo $LISTLEN
CHECKDATE=`date +"%F"`
#双循环,判断是否有内容更新i为新内容,j为旧内容
for ((i=0;i<LISTLEN;i++))
do
#echo ${oldPAGELIST[$count]} is over
	#c=0
	c=0
	for ((j=0;j<LISTLEN;j++))
	do
	#新内容比较旧内容
		
#		echo ${newPAGELIST[$i]} nnnn
#		echo ${oldPAGELIST[$j]} oooo
	#如果新内容在旧内容中存在几次,c自增几次,0次为新内容,大于0次为旧内容
		if [ "${newPAGELIST[$i]}" = "${oldPAGELIST[$j]}" ] ; then	
		((c++))
		#echo $c jj
		#else
		#echo $c ee
		fi
	done		
			if [ $c -eq 0 ];then
				#根据时间建立目录
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
			echo 软件学院教务更新了 $t  下载地址:$FILEURL 程序在 $TIME 检测到
			#curl -u $LOGIN -Fstatus="软件学院教务更新了 $t,下载地址:$FILEURL" http://api.jiwai.de/statuses/update.json
				
				
			#else
				#if [ $c -eq 1 ];then
				#echo ${newPAGELIST[$i]}is same with ${oldPAGELIST[$j]}
				
				
				#fi
			fi
done	
cp $CHECKPATH/newpage.txt $CHECKPATH/oldpage.txt --reply=yes
