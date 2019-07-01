SRCHTAB	;
	new r
	set r=""
	write "<html>",!
	for  set r=$order(^INDX2(r)) quit:r=""  do
	.do HTML(r,0)
	.quit
	write !,"</html>"
	quit
	
HTML(r,toptag)
	new param,xpath1,xpath2,type
	if toptag do
	.write "<html>"
	.quit
	w "<table border=1>",!
	w "<td><b>",r,"</b></td><td></td><td></td><td></td><tr>",!
	w "<td>search param</td><td>type</td><td>xpath-1</td><td>xpath-2</td><tr>",!
	set param=""
	for  set param=$order(^INDX2(r,param)) quit:param=""  do
	.set xpath1=$get(^INDX2(r,param,"xpath"))
	.set xpath2=$get(^INDX2(r,param,"xpath",2))
	.set type=$get(^INDX2(r,param,"type"))
	.w "<td>",param,"</td><td>",type,"</td><td>",xpath1,"</td><td>",xpath2,"</td><tr>",!
	.quit
	w "</table>",!
	if toptag w "</html>"
	quit