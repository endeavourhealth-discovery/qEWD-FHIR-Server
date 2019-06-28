SORT	;
SORTIT(resource,var)
	new cnt,i,ret,id,qvar,data,q,qf,glb,rec
	
	kill ^tsort($job)
	
	; ^INDX("Encounter","date","exp")=" Encounter.period "
	; ^INDX("Encounter","date","xpath")=" f:Encounter/f:period "
	;^documents("Encounter","313129d0-084a-4aaf-b0ce-2ea9cac7d9d5","period","end")=2017-03-23T10:00:00+00:00
	;^documents("Encounter","313129d0-084a-4aaf-b0ce-2ea9cac7d9d5","period","start")=2019-03-23T09:00:00+00:00
	;^documents("Encounter","68f3cbc1-0e51-4f2d-b686-326a24b5fc04","period","end")=2019-03-03T10:00:00+00:00
	;^documents("Encounter","68f3cbc1-0e51-4f2d-b686-326a24b5fc04","period","start")=2019-03-02T09:00:00+00:00
	
	set cnt=""
	for  set cnt=$order(^temp($j,"Ids",cnt)) quit:cnt=""  do
	.set rec=^(cnt),id=$p(rec,"|")
	.; get each variable and sort it!
	.set data=""
	.for i=1:1 quit:$piece(var,",",i)=""  do
	..set qvar=$piece(var,",",i)
	..if qvar="" quit
	..if $extract(qvar)="-" set qvar=$extract(qvar,2,99) ; descending?
	..set data=data_$$DATA(resource,qvar,id)_"~"
	..quit
	.set glb="set ^tsort($j,"
	.for i=1:1:$l(data,"~") do
	..quit:$piece(data,"~",i)=""
	..set glb=glb_""""_$$LC^UTILS($piece(data,"~",i))_""","
	..quit
	.S glb=glb_""""_id_""")="""""
	.Xecute glb
	.quit
	
	D RTN(var,resource)
	
	quit

WRITEFIL ;
	set sd="/tmp/test1.txt"
	open sd:(newversion:stream:nowrap:chset="M")
	use sd
	write "hello world!"
	close sd
	QUIT
	
	; create a routine to traverse ^tsort($j) <= forwards and backwards
	; family,given
RTN(var,resource)
	new loop,r,rtnid,c,i,dots,routine,z
	kill ^TRTN($j)
	set loop=$length(var)
	set c=1
	
	; ^tsort($job,a,b,id)
	set rtnid=$i(^RTN)
	
	set r="RTN"_rtnid_";"
	set ^TRTN($job,c)=r,c=$i(c)
	
	; initialize the variables
	set var=var_",id"
	for i=1:1:$length(var,",") do
	.set n=$piece(var,",",i)
	.if $extract(n,1)="-" set n=$extract(n,2,99)
	.set r=" set "_n_"="""""
	.set ^TRTN($job,c)=r
	.set c=$i(c)
	.quit
	
	; traverse the nodes
	for i=1:1:$length(var,",") do
	.set var(i)=$piece(var,",",i)
	.quit
	
	set r=" kill ^temp($j,""Ids"")"
	set ^TRTN($J,c)=r,c=$i(c)
	set r=" set cnt=1"
	set ^TRTN($J,c)=r,c=$i(c)
	
	set r=" s resource="""_resource_""""
	set ^TRTN($J,c)=r,c=$i(c)
	
	set i=""
	for  s i=$order(var(i)) quit:i=""  do
	.set var=var(i)
	.set direction=1
	.if $extract(var)="-" set direction="-1"
	.set vars=""
	.for z=1:1:i do
	..set vars=vars_$select($extract(var(z))="-":$extract(var(z),2,99),1:var(z))_","
	..quit
	.set vars=$extract(vars,1,$length(vars)-1)
	.set z=$s($e(var)="-":$e(var,2,99),1:var)
	.set r="for  set "_z_"=$order(^tsort($j,"_vars_"),"_direction_") quit:"_z_"=""""  do"
	.set dots=""
	.if i>1 s dots=$$TR^UTILS($j(dots,i-1)," ",".")
	.set r=" "_dots_r
	.set ^TRTN($J,c)=r,c=$i(c)
	.quit
	
	set dots=dots_"."
	set r=" "_dots_"set ^temp($j,""Ids"",cnt)=id_""|""_resource"
	set ^TRTN($J,c)=r,c=$i(c)
	set r=" "_dots_"set cnt=$i(cnt)"
	set ^TRTN($J,c)=r,c=$i(c)
	
	; write the routine to disk and run it!
	set sd="/root/.yottadb/r/RTN"_rtnid_".m"
	open sd:(newversion:stream:nowrap:chset="M")
	use sd
	set c=""
	for  set c=$order(^TRTN($J,c)) quit:c=""  do
	.write ^(c),!
	.quit
	close sd
	
	; run the routine!
	set routine="^RTN"_rtnid
	
	write !,"running routine: ",routine,!
		
	do @routine
	
	quit
	
DATA(resource,var,id)
	new q,qf,i,data,prop,type,qdata,xpath
	
	set qf=0,data=""
    set q="^documents("""_resource_""","""_id_""")",z=0
	
	set data=""
	kill prop
	
	; Organization alias/name scenario
	set xpath=$g(^INDX2(resource,var,"xpath"))
	if '$data(^docindex3(xpath)) set xpath=$get(^INDX2(resource,var,"xpath",2))
	
    for  s q=$q(@q) q:q=""  do  q:qf
	.if $qsubscript(q,2)'=id set qf=1 q
	.set prop=$$GETPROP^INDEX3(q,resource)
	.set qdata=@q
	.set type=$$TYPE2^UTILS(var)
	.;W !,var," * ",prop," * ",q
	.;W !,"x: ",xpath
	.if type["date"!(type="Period") set qdata=$$HORO^UTILS($$LC^UTILS(qdata))
	.if xpath=prop set data=qdata
	.;write !,"sort [",data,"]"
	.quit
	
	quit data