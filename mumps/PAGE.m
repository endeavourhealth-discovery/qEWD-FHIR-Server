PAGE	;
STT(srch,thequery,resource)
	new queryid,page,cnt,next,previous,last,uri,z
	
	set uri="http://127.0.0.1:8080/fhir/STU3/"_resource_"?"
	
	set queryid=$get(srch("data","queryid"))
	set page=$get(srch("data","page"))
	
	if queryid="" quit
	if page="" quit
	
	set ^PAGE=queryid_"~"_page_"~"_thequery
	
	set cnt="",z=1
	kill ^temp($j)
	for  set cnt=$order(^TPAGE(queryid,page,cnt)) quit:cnt=""  do
	.set ^temp($j,"Ids",z)=^(cnt)
	.set z=$increment(z)
	.quit
	
	set ^temp($j,"howmany")=(z-1)
	set ^temp($j,"self")=thequery
	
	; first
	set ^temp($j,"first")=uri_"page=1&queryid="_queryid
	
	; last
	set last=$order(^TPAGE(queryid,""),-1)
	set ^temp($j,"last")=uri_"page="_last_"&queryid="_queryid
	
	; next
	set next=page+1
	if '$data(^TPAGE(queryid,next)) S next=last
	set ^temp($j,"next")=uri_"page="_next_"&queryid="_queryid
	
	; previous
	set previous=next-1
	set ^temp($j,"previous")=uri_"page="_previous_"&queryid="_queryid
	
	quit
	