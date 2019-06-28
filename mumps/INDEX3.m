INDEX3	;
	;
INDEX2(id,resource)
	new qf,q,z,value,var,type,node,i,sub,prop,number,code,c
	
	set $ECODE=""
	set $ETRAP="GOTO ET^UTILS"
	
	kill ^TCODES($job)
	
	do:'$data(^INDX2(resource)) INDX2^UTILS(resource)
	
	set qf=0
    set q="^documents("""_resource_""","""_id_""")",z=0
	
	set code=""
	
    for  set q=$q(@q) q:q=""  do  q:qf
	.if $qsubscript(q,2)'=id set qf=1 q
	.set value=$extract($$LC^UTILS(@q),1,100)
	.set number=0
	.if $c(0)]]value s number=1
	.;w !,q
	.set prop=$$GETPROP(q,resource)
	.;w !,"[",prop,"]"
	.quit:prop=""
	.set type=$$TYPE2^UTILS(prop)
	.;w !,type
	.D CODES(q,type,prop)
	.if type["date"!(type="Period") set value=$$HORO^UTILS(value)
	.else  set value=value_" "
	.if type="Quantity",number set value=+value
	.set ^docindex3(prop,value,id)=""
	.Q
	
	set ^temp($j,1)="ok"
	
	w !
	zwr code
	
	set c=""
	for  s c=$order(^TCODES($job,c)) quit:c=""  do
	.set code=$get(^TCODES($job,c,"c"))
	.set codeprop=$get(^TCODES($job,c,"prop"))
	.set value=$get(^TCODES($job,(c+1),"v"))
	.if value'="" set valprop=$get(^TCODES($job,(c+1),"prop"))
	.w !,"[",value,"]"
	.if value'="" set ^AXIN(valprop,"N",value,code,id)="",^AXINR(id,"N",code,value,valprop)=""
	.if code'="" set ^AXIN(codeprop,"X",code,id)="",^AXINR(id,"X",code,codeprop)=""
	.quit
	quit 1
	
CODES(q,type,prop)
	new qlength,node,c
	W !,q
	set qlength=$qlength(q)
	set node=$qsubscript(q,qlength)
	if type="CodeableConcept",node="code" set c=$order(^TCODES($j,""),-1)+1 set ^TCODES($J,c,"c")=@q,^TCODES($J,c,"prop")=prop
	if type="Quantity",node="value" set c=$order(^TCODES($j,""),-1)+1 set ^TCODES($J,c,"v")=@q,^TCODES($J,c,"prop")=prop
	quit
	
GETPROP(q,resource)
	new prop,node,i,sub,z,xpath,got
	
	set node=""
	for i=$qlength(q):-1:2 do
	.set sub=$qsubscript(q,i)
	.quit:sub?1n.n
	.set $piece(node,".",(i-2))=sub
	.q
	
	set z=""
	for i=1:1:$length(node,".") set:$piece(node,".",i)'="" z=z_$p(node,".",i)_"."
	set z=$extract(z,1,$length(z)-1)
	
	set (q,xpath,got)=""
	
	for i=1:1:$length(z,".") do
	.set q=q_$piece(z,".",i)_"."
	.set xpath=$e(q,1,$l(q)-1)
	.if $data(^XPATH2(resource_"."_xpath)) set got=resource_"."_xpath
	.quit
	
	quit got
	