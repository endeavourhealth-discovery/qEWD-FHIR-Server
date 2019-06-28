SRCH	;
SEARCH(query,resource)
	new srch,err,value,prop,type,id,all,i,include,cnt,res,ops,howmany,z,sort,l,rev,r,inner,xpath,rec,ref,thequery,url,code
	
	set ^Q=query_"~"_resource
	
	set $ECODE=""
	set $ETRAP="GOTO ET^UTILS"
	
	if '$data(^INDX2(resource)) quit 0
	
	kill ^temp($j),^tempx($j),^TINC($j),^TREV($j),^TSORT($j),^TCOUNT($j),^tkill($j)
		
	do DECODE^VPRJSON($name(query),$name(srch),$name(err))

	kill ^SRCH
	merge ^SRCH=srch
	
	set prop="",ops=0
	
	; the actual query
	set (prop,i,thequery)=""
	for  set prop=$order(srch("data","thequery",prop)) quit:prop=""  do
	.set r=$get(srch("data","thequery",prop))
	.if r'="" set thequery=thequery_prop_"="_r_"&"
	.for  set i=$order(srch("data","thequery",prop,i)) quit:i=""  do
	..set r=$get(srch("data","thequery",prop,i))
	..if r'="" set thequery=thequery_prop_"="_r_"&"
	..quit
	.quit
	
	set all=0
	if thequery'["&" set all=1
	
	write !,"all=",all
	
	set url="http://127.0.0.1:8080/fhir/STU3/"_resource
	if thequery'="" set thequery=url_"?"_thequery if thequery["&" set thequery=$extract(thequery,1,$length(thequery)-1)
	
	write !,"thequery: ",thequery
	
	; do we need to return a page?
	if $data(srch("data","thequery","queryid")) D STT^PAGE(.srch,thequery,resource) quit 1
	
	; dates
	set (prop,i)=""
	for  set prop=$order(srch("data","thequery",prop)) quit:prop=""  do
	.for  set i=$order(srch("data","thequery",prop,i)) quit:i=""  do
	..quit:$get(srch("data","thequery",prop,i))=""
	..set srch("data","thequery",(prop_"~"_i))=srch("data","thequery",prop,i)
	..quit
	.quit
	
	for  set prop=$Order(srch("data","thequery",prop)) quit:prop=""  do
	.if prop="_count" set ^TCOUNT($J,1)=srch("data","thequery",prop) quit
	.if prop="_sort" set ^TSORT($J,1)=srch("data","thequery",prop) quit
	.if prop="_revinclude" do  quit
	..if $get(srch("data","thequery",prop))="" merge ^TREV($J)=srch("data","thequery","_revinclude") quit
	..set i=+$i(^TREV($J))
	..set ^TREV($J,i)=srch("data","thequery",prop)
	..quit
	.if prop="_include" do
	..if $get(srch("data","thequery",prop))="" merge ^TINC($J)=srch("data","thequery","_include") quit
	..set i=+$i(^TINC($J))
	..set ^TINC($J,i)=srch("data","thequery",prop)
	..quit
	.set value=$Get(srch("data","thequery",prop))
	.if value="" quit
	.set z=$piece(prop,"~") ; dates
	.write !,"[",z,"]"
	.; reference?
	.if z[":" Do ZREF(resource,z,value,.ops) quit
	.if '$Data(^INDX2(resource,z)) w !,"quit ",z quit
	.set type=$Get(^INDX2(resource,z,"type"))
	.if type="" QUIT
	.set ops=ops+1
	.; Does the param string contain a codeable concept?
	.set code=$$CODE(resource,.srch)
	.do GO(resource,z,value,type,code)
	.quit
	
	do:all ALL(resource)
	
	write !,"**********"
	write !,ops," * ",all
	write !,"**********"
	
	do COUNT
	
	if ops>1,'all Do
	.set id="",howmany=0
	.for  set id=$order(^tempx($j,id)) quit:id=""  do
	..if ^tempx($j,id)'=ops Do K(id) quit
	..set howmany=howmany+1
	..quit
	.set ^temp($j,"howmany")=howmany
	.quit
	
	do TIDY

	kill ^tinc($j)
	if $data(^TINC($J)) Do
	.for i=1:1:$order(^TINC($J,""),-1) do
	..; e.g. Patient:general-Practitioner
	..set include=^TINC($J,i)
	..set res=$P(include,":"),z=$P(include,":",2)
	..; loop down the existing ids & add the extra resources to ^temp($j,"Ids")
	..set cnt=""
	..for  set cnt=$Order(^temp($j,"Ids",cnt)) quit:cnt=""  do
	...set id=^(cnt)
	...do INCLUDE(res,id,z)
	...quit
	..quit
	.quit
	
	set sort=$get(^TSORT($J,1))
	if sort'="" do SORTIT^SORT(resource,sort)
	
	;_include
	s cnt=$o(^temp($j,"Ids",""),-1)+1
	s l="" f  s l=$o(^tinc($j,"Ids",l)) q:l=""  s ^temp($j,"Ids",cnt)=^tinc($j,"Ids",l),cnt=cnt+1

	; _revinclude
	if $data(^TREV($J)) do
	.set i=""
	.for  set i=$order(^TREV($J,i)) quit:i=""  do
	..set rev=^TREV($J,i)
	..set r=$piece(rev,":"),inner=$piece(rev,":",2)
	..if r="*" do revstar quit
	..if inner="" quit
	..set xpath=$get(^INDX2(r,inner,"xpath"))
	..if xpath="" quit
	..set cnt=""
	..F  set cnt=$order(^temp($j,"Ids",cnt)) q:cnt=""  do
	...set rec=^(cnt)
	...if $$LC^UTILS($piece(rec,"|",2))'=inner quit
	...set id=$piece(rec,"|"),ref=(inner_"/"_id_" "),z=""
	...for  set z=$order(^docindex3(xpath,ref,z)) q:z=""  do
	....if $data(^documents(r,z)) set n=$order(^temp($J,"Ids",""),-1)+1,^temp($j,"Ids",n)=z_"|"_r_"|INC"
	....quit
	...quit
	..set ref=inner_"/"
	..quit
	.quit

	; page if total > 99
	if '$data(^TCOUNT($job)),$order(^temp($j,"Ids",""),-1)>99 set ^TCOUNT($j,1)=100
	
	; _count	
	if $data(^TCOUNT($job)) do
	.new page,queryid,count,cnt,uri,last
	.set uri="http://127.0.0.1:8080/fhir/STU3/"_resource_"?"
	.set queryid=$$UUID^UTILS()
	.kill ^TPAGE(queryid)
	.set count=^TCOUNT($job,1)
	.set id="",cnt=1,page=1
	.for  set id=$order(^temp($j,"Ids",id)) quit:id=""  do
	..set ^TPAGE(queryid,page,cnt)=^temp($j,"Ids",id)
	..if cnt#count=0 set page=$increment(page),cnt=0
	..set cnt=$i(cnt)
	..quit
	.if $data(^TPAGE(queryid,2)) do
	..set ^temp($j,"first")=uri_"page=1&queryid="_queryid
	..set ^temp($j,"previous")=uri_"page=1&queryid="_queryid
	..set ^temp($j,"next")=uri_"page=2&queryid="_queryid
	..set ^temp($j,"self")=thequery
	..set last=$order(^TPAGE(queryid,""),-1)
	..set ^temp($j,"last")=uri_"page="_last_"&queryid="_queryid
	..set ^temp($j,"bundletot")=$order(^temp($j,"Ids",""),-1)
	..; kill everything apart from the first page!
	..kill ^temp($j,"Ids")
	..set cnt=""
	..for  set cnt=$order(^TPAGE(queryid,1,cnt)) quit:cnt=""  set ^temp($j,"Ids",cnt)=^(cnt)
	..quit
	.quit
	
	set ^temp($j,"howmany")=$order(^temp($j,"Ids",""),-1)
	quit 1

revstar	;
	new cnt,rec,id
	set cnt=""
	for  set cnt=$order(^temp($j,"Ids",cnt)) q:cnt=""  do
	.set rec=^temp($j,"Ids",cnt)
	.if $p(rec,"|",2)'="Patient" quit
	.set id=$piece(rec,"|",1)
	.D FINDREV^EVERYTHING(id)
	.quit
	quit
	
CODE(resource,srch)
	new param,code
	set (code,param)=""
	for  set param=$order(srch("data","thequery",param)) quit:param=""  do
	.if $get(^INDX2(resource,param,"type"))="CodeableConcept" set code=srch("data","thequery",param)
	.quit
	quit code
	
	; https://hl7.org/fhir/2018May/search.html
GO(r,prop,value,type,code)
	new i,node,loop,exp
	
	set exp=$get(^INDX2(r,prop,"xpath"))
	if '$data(^docindex3(exp)) set exp=$get(^INDX2(r,prop,"xpath",2))
	
	if exp="" quit ; !
	
	write !,"*********************"
	write !,prop," * ",exp
	write !,"*********************"

	write !,exp,"*",value,"*",type,"*",prop,"*",code

	do LOOP(exp,value,type,r,code)
	
	quit

LOOP(exp,value,type,r,code)
	new loop,q,id,cnt,exact
	
	set exp=$$TR^UTILS(exp," ","")
	set id=""

	set loop=$$LC^UTILS(value),q=0
	set cnt=0

	set ^temp($j,"search")=exp
	Set cnt=$Order(^temp($j,"Ids",""),-1)

	if type["date" do LOOPBDAT(value,cnt,exp,r) quit ; ** EXIT **
	if type="Quantity",code'="" do AXIN(value,cnt,exp,r,code) quit ; ** EXIT **

	write !,exp
	
	set exact=0
	if value["|" set value=$P(value,"|",2),loop=$$LC^UTILS(value),exact=1
	set q=0,id=""

	write !,"in loop ",exp

	if $data(^docindex3(exp,(loop_" "))) do
	.for  set id=$o(^docindex3(exp,(loop_" "),id)) quit:id=""  do
	..set cnt=cnt+1
	..write !,loop,"a * ",id," * ",cnt
	..set ^temp($j,"Ids",cnt)=id_"|"_r
	..set ^tkill($j,id,cnt)=""
	..set:value'="" ^tempx($j,id,exp,$$LC^UTILS(value))=""
	..quit
	.quit
	
	if exact set ^temp($j,"howmany")=+$get(cnt) quit
	
	for  set loop=$Order(^docindex3(exp,loop)) quit:loop=""  do  quit:q
	.if $extract(loop,1,$l(value))'=$$LC^UTILS(value) set q=1 Q
	.for  set id=$O(^docindex3(exp,loop,id)) quit:id=""  do
	..set cnt=cnt+1
	..write !,loop,"b * ",id," * ",cnt
	..set ^temp($j,"Ids",cnt)=id_"|"_r
	..set ^tkill($j,id,cnt)=""
	..set:value'="" ^tempx($j,id,exp,$$LC^UTILS(value))=""
	..quit
	.quit

	set ^temp($j,"howmany")=+$get(cnt)
	quit

AXIN(value,cnt,exp,r,code)
	new loop,z,id,q,prefix,val,ne
	
	write !,"in axin loop"
	write !,value
	write !,exp
	
	set (z,q,ne)=0,id=""
	
	set prefix=$$GETPREFIX^UTILS(value)
	if prefix'="" do
	.set val=$extract(value,3,99)
	.write !,"value: ",val
	.if prefix="eq" set loop=val-1,z=loop
	.if prefix="ne" set loop="",ne=1,z=val
	.if prefix="lt" set loop="",z=val
	.if prefix="gt" set loop=val,z=99999
	.if prefix="ge" set loop=val-1,z=99999
	.if prefix="le" set loop="",z=val+1
	.quit
	
	if prefix="" set loop=value-1,z=loop
	
	write !,"loop = ",loop," * ",z," * ",exp
	
	for  set loop=$order(^AXIN(exp,"N",loop)) quit:loop=""  do  quit:q
	.w !,"** loop: ",loop," * ",q," * ",ne," * ",z
	.if ne,loop=z quit
	.if 'ne,loop>z S q=1 quit
	.for  set id=$order(^AXIN(exp,"N",loop,code,id)) quit:id=""  do
	..set cnt=cnt+1
	..W !,"*** ",value," * ",code," * ",id," * ",loop
	..set ^temp($j,"Ids",cnt)=id_"|"_r
	..set ^tkill($j,id,cnt)=""
	..set ^tempx($j,id,exp,$$LC^UTILS(value))=""
	..quit
	.quit	
	
	quit
	
LOOPBDAT(value,cnt,exp,r)
	new loop,z,id,q,prefix,val,ne

	write !,"In date loop"
	write !,value
	write !,exp
	
	set (z,q,ne)=0,id=""
	
	; eq = equal to
	; ne = not equal to
	; lt = less than
	; gt = greater than
	; ge = greater than or equal to
	; le = less than or equal to
	
	set prefix=$$GETPREFIX^UTILS(value)
	if prefix'="" do
	.set val=$extract(value,3,99)
	.write !,"value: ",val
	.if prefix="eq" set loop=$$HORO^UTILS(val)-1,z=loop
	.if prefix="ne" set loop="",ne=1,z=$$HORO^UTILS(val)
	.if prefix="lt" set loop="",z=$$HORO^UTILS(val)
	.if prefix="gt" set loop=$$HORO^UTILS(val),z=94234 ; 01/01/2099
	.if prefix="ge" set loop=$$HORO^UTILS(val)-1,z=94234
	.if prefix="le" set loop="",z=$$HORO^UTILS(val)+1
	.quit
	
	if prefix="" set loop=$$HORO^UTILS(value)-1,z=loop
	
	; partial date, then adjust z to the end of the year or month
	set val=value
	if prefix'="" set val=$extract(value,3,99)
	if $length(val)=4 set z=$$FUNC^%DATE("12/31/"_val)
	
	write !,"loop = ",loop," * ",z," * ",exp
	
	for  set loop=$order(^docindex3(exp,loop)) quit:loop=""  do  quit:q
	.w !,"** loop: ",loop," * ",q," * ",ne," * ",z
	.if ne,loop=z quit
	.if 'ne,loop>z S q=1 quit
	.for  set id=$order(^docindex3(exp,loop,id)) quit:id=""  do
	..set cnt=cnt+1
	..W !,"*** ",value," * ",id," * ",$zdate(loop)
	..set ^temp($j,"Ids",cnt)=id_"|"_r
	..set ^tkill($j,id,cnt)=""
	..set ^tempx($j,id,exp,$$LC^UTILS(value))=""
	..quit
	.quit
	
	set ^temp($j,"howmany")=+$get(cnt)

	quit

ZREF(resource,prop,value,ops)
	new i,z,qf,exp,val

	write !,"in zref"

	set exp=resource_"."_$piece(prop,":")
	write !,exp
		
	for z=1:1:$l(value,"|") do
	.set val=$p(value,"|",z)
	.do LOOP(exp,val,"reference",resource)
	.set ops=ops+1
	.quit
	
	quit

COUNT	;
	new id,prop,value
	set (id,prop,value)=""
	for  set id=$order(^tempx($j,id)) quit:id=""  do
	.for  set prop=$order(^tempx($j,id,prop)) quit:prop=""  do
	..for  set value=$order(^tempx($j,id,prop,value)) quit:value=""  do
	...set ^tempx($j,id)=$get(^tempx($j,id))+1
	...quit
	..quit
	.quit
	quit

TIDY	;
	new c,cnt,rec,id
	kill ^temp2($j),^tid($j)
	set c="",cnt=1
	for  set c=$order(^temp($j,"Ids",c)) quit:c=""  do
	.set rec=^(c),id=$Piece(rec,"|",1)
	.if $data(^tid($j,id)) quit
	.set ^tid($j,id)=""
	.set ^temp2($j,"Ids",cnt)=rec,cnt=cnt+1
	.quit

	kill ^temp($j,"Ids")
	merge ^temp($j,"Ids")=^temp2($j,"Ids")
	quit

INCLUDE(res,id,z)
	new ref,rlink,rid,cnt
	
	; does Patient:general-Practitioner exist in the resource?
	; ?
	set z=$$TR^UTILS(z,"-",""),id=$piece(id,"|")
	
	set ref=$get(^documents(res,id,z,"0","reference"))
	; might not be an array
	set:ref="" ref=$get(^documents(res,id,z,"reference"))
	set rlink=$piece(ref,"/"),rid=$piece(ref,"/",2)
	if rlink'="",rid'="",$data(^documents(rlink,rid)) set cnt=$order(^tinc($j,"Ids",""),-1)+1,^tinc($j,"Ids",cnt)=rid_"|"_rlink_"|INC"
	quit
	
K(id)	;
	new cnt
	;W !,id
	;Set cnt=""
	;for  set cnt=$order(^temp($j,"Ids",cnt)) quit:cnt=""  if $p(^(cnt),"|")=id Kill ^temp($j,"Ids",cnt)
	set cnt=""
	for  set cnt=$order(^tkill($j,id,cnt)) quit:cnt=""  kill ^temp($j,"Ids",cnt)
	quit

ALL(resource)
	new id,cnt
	
	J MEM
	
	set id="",cnt=1
	for  set id=$Order(^documents(resource,id)) quit:id=""  set ^temp($j,"Ids",cnt)=id_"|"_resource,cnt=cnt+1
	set ^temp($j,"howmany")=$order(^temp($j,"Ids",""),-1)
	
	quit
	
MEM	;
	; pull ^documments into memory
	set id=""
	for  set id=$Order(^documents(resource,id)) quit:id=""
	quit