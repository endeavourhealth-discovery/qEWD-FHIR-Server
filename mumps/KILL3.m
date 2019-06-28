KILL(resource,id)
	new qf,q,z,n,data,y,var,type

	set $ECODE=""
	set $ETRAP="GOTO ET^UTILS"
	
	set ^KILL=resource_"~"_id
	
	set qf=0
    set q="^documents("""_resource_""","""_id_""")",z=0
    for  set q=$query(@q) q:q=""  do  quit:qf
    .if $piece(q,""",""",2)'=id s qf=1 q
	.set data=$Extract($$LC^UTILS(@q),1,100)
	.set number=0
	.if $c(0)]]data s number=1
	.set prop=$$GETPROP^INDEX3(q,resource)
	.quit:prop=""
	.set type=$$TYPE2^UTILS(prop)
	.if type["date"!(type="Period") set data=$$HORO^UTILS(data)
	.else  set data=data_" "
	.if type="Quantity",number set data=+data
	.w !,prop," * ",data," * ",id
	.kill:prop'="" ^docindex3(prop,data,id)
	.w !,prop,",",data,",",id
	.q

	; ^AXIN
	DO AXINR(id,resource)
	
	Kill ^documents(resource,id)
	
	set ^temp($j,1)="ok"
	
	Q 1
	
AXINR(id,resource)
	new code,value,valprop
	new codeprop
	set (code,value,valprop)=""
	f  s code=$o(^AXINR(id,"N",code)) q:code=""  d
	.f  s value=$o(^AXINR(id,"N",code,value)) q:value=""  d
	..f  s valprop=$o(^AXINR(id,"N",code,value,valprop)) q:valprop=""  d
	...kill ^AXIN(valprop,"N",value,code,id)
	...;kill ^docindex3(valprop,value,id) ; pick up the pieces
	set codeprop=""
	f  s code=$o(^AXINR(id,"X",code)) q:code=""  d
	.f  s codeprop=$o(^AXINR(id,"X",code,codeprop)) q:codeprop=""  d
	..kill ^AXIN(codeprop,"X",code,id)
	quit