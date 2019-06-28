UTILS	;
	;

ET	; write error to console and log error in ^ZERROR
	new I,K,J,H
	kill ^temp($j)
    write !,"CONTINUING WITH ERROR TRAP AFTER AN ERROR" 
    write !,"$STACK: ",$STACK 
    write !,"$STACK(-1): ",$STACK(-1) 
    write !,"$ZLEVEL: ",$ZLEVEL
	set H=$Horolog
	set ^ZERROR(H)=$ZSTATUS
    for I=$STACK(-1):-1:1 DO 
    .write !,"LEVEL: ",I 
    .set K=10
    .for J="PLACE","MCODE","ECODE" do 
    ..write ?K," ",J,": ",$STACK(I,J)
	..set ^ZERROR(H,I,J)=$STACK(I,J)
    ..set K=K+20 
    write !,$ZSTATUS,!
    ZSHOW "S" 
    set $ECODE="",$ZTRAP=""
	set ^temp($j,"error",1)="**ErRoR: "_$ZSTATUS
	QUIT 1

	; does a prefix exist?
	; eq = equal to
	; ne = not equal to
	; lt = less than
	; gt = greater than
	; ge = greater than or equal to
	; le = less than or equal to
GETPREFIX(value)
	new prefix,q
	set q=0
	set prefix=$extract(value,1,2)
	if "\eq\ne\lt\gt\ge\le\"[("\"_prefix_"\") s q=1
	if 'q set prefix=""
	quit prefix
	
	; need a param to say if the date is a start date or an end date?
HORO(date)
	new yotta,dd,mm,yyyy
	
	set date=$P($$TR(date,"-","/"),"t")
	
	set dd=$P(date,"/",3),mm=$P(date,"/",2),yyyy=$P(date,"/",1)
	
	if $Length(date)=4 S yotta="01/01/"_yyyy
	if $Length(date)=7 S yotta=mm_"/01/"_yyyy
	
	set:'$data(yotta) yotta=mm_"/"_dd_"/"_yyyy
	
	quit $$FUNC^%DATE(yotta)

	; Lowercase
LC(v) Set v=$TR(v,"ABCDEFGHIJKLMNOPQRSTUVWXYZ","abcdefghijklmnopqrstuvwxyz")
 	Q v
 
TR(ZX,ZY,ZZ) ; Function to replace strings within strings with other strings
 	;ZX is the variable
	;ZY is the string to be replaced
 	;ZZ is the string to replace the old one
 	New ZW
 	Set ZW=0
 	For  S ZW=$FIND(ZX,ZY,ZW) Q:ZW=0  S ZW=ZW-$LENGTH(ZY)-1 S ZX=$EXTRACT(ZX,1,ZW)_ZZ_$EXTRACT(ZX,ZW+$LENGTH(ZY)+1,$LENGTH(ZX)),ZW=ZW+$LENGTH(ZZ)+1
 	Q ZX

	; p references ^Documents
	; store json ^RAWJSON
	; used before processing references
A(p,json)
	n inputs,outputs,l

	if $get(^RAWJSON(p))="" set ^RAWJSON(p)=$H_":"_$ZDATE($H,"DD/MM/YYYY 12:60:SS AM")
	
	set l=$order(^RAWJSON(p,""),-1)+1
	set ^RAWJSON(p,l)=json

	; p id
	;k ^traw($j)
	;s sd="/tmp/"_id_".json"
  	;open sd:(readonly:exception="do BADOPEN")
  	;use sd:exception="goto EOF"
  	;for  use sd read x use $principal write x,!
 	;EOF;
  	;if '$zeof ; zmessage +$zstatus
  	;close sd

	Kill ^inputs
	merge ^inputs($J)=^temp($j)
	;s outputs="{""dir"": ""/opt/qewd/mapped/db_service/fhirsearch/standard/STU3/schema""}"
	kill ^temp($j)
	set outputs(1)="hello"
	set outputs(2)="world"
	merge ^temp($j)=outputs
	Q 1

RESET	;
	Kill ^docindex,^documents,^documentsver,^docindex2,^INDX,^XPATH
	Kill ^XPATH2,^INDX2,^docindex3,^AXIN,^AXINR
	; debug and temp globals
	Kill ^RAWJSON,^Q,^KILL,^SRCH,^TINC,^TSORT,^temp,^temp2,^tempx,^tid,^tinc,^inputs,^TPAGE,^TCOUNT,^tsort,^ZERROR,^ps2,^test,^TRTN,^TCODES,^TREV,^tkill
	kill ^PAGE
	QUIT

PTS()	; List the patients in the system
	new id,family,given,gender,nhsno,dob
	Set id=""
	for  set id=$order(^documents("Patient",id)) quit:id=""  do
	.set family=^documents("Patient",id,"name",0,"family")
	.set given=^documents("Patient",id,"name",0,"given",0)
	.set gender=^documents("Patient",id,"gender")
	.set nhsno=$g(^documents("Patient",id,"identifier",0,"value"),"?")
	.set dob=$get(^documents("Patient",id,"birthDate"))
	.write !,id," * ",family," * ",given," * ",gender," * ",nhsno," * ",dob
	.q
	QUIT

GETPROP(q,resource)
	n prop,var,node,i,sub
	set var=$qsubscript(q,$qlength(q))
	if var?1n.n set var=$qsubscript(q,$qlength(q)-1)
	set node=""
	for i=3:1:$qlength(q) do
	.set sub=$qsubscript(q,i)
	.if sub="end"!(sub="start") q
	.set:sub'?1n.n node=node_sub_"."
	.q
	set prop=$e(node,1,$l(node)-1)
	set prop=resource_"."_prop
	Q prop

UUID() ; GENERATE A RANDOM UUID (Version 4) 
	new I,J,ZS 
	set ZS="0123456789abcdef",J="" 
	for I=1:1:36 S J=J_$select((I=9)!(I=14)!(I=19)!(I=24):"-",I=15:4,I=20:"a",1:$extract(ZS,$random(16)+1)) 
	quit J 
 
TYPE(prop)
	new i,type,z
	set type=""
	
	set ^ps($o(^ps(""),-1)+1)=prop
	
	for i=$length(prop,"."):-1 quit:$piece(prop,".",i)=""  set z=$p(prop,".",1,i) if $get(^XPATH(z,"type"))'="" set type=$g(^XPATH(z,"type")) quit
	quit type
	
TYPE2(prop)
	new i,type,z
	set type=""
	
	set ^ps2($o(^ps2(""),-1)+1)=prop
	
	for i=$length(prop,"."):-1 quit:$piece(prop,".",i)=""  set z=$p(prop,".",1,i) if $get(^XPATH2(z,"type"))'="" set type=$g(^XPATH2(z,"type")) quit
	QUIT type
	
CLEANXPATH(xpath)
	set xpath=$$TR^UTILS(xpath,"f:","")
	set xpath=$$TR^UTILS(xpath,"/",".")
	set xpath=$$TR^UTILS(xpath," ","")
	QUIT xpath

INDX2(a) ; Create an xpath index from ^SYNSCHEMA rather than ^Schemas
	; ^SYNSCHEMA is a copy of ^["FHIRBUS"]SynFHIR.Schemas
	new b,path
	
	kill ^INDX2(a)
	
	set b=""
	for  set b=$order(^SYNSCHEMA("STU3","Resource",a,"e",b)) quit:b=""  do
	.set path=$get(^SYNSCHEMA("STU3","Resource",a,"e",b,"path",1))
	.set type=$order(^SYNSCHEMA("STU3","Resource",a,"e",b,"datatype",""))
	.if type'="" set type=^(type)
	.if path'="" do
	..set ^XPATH2(a_"."_path,"type")=type
	..set ^XPATH2(a_"."_path,"name")=a_"."_path
	..; ^SYNSCHEMA("STU3","Resource","Organization","e","name","path",1)="alias"
	..; ^SYNSCHEMA("STU3","Resource","Organization","e","name","path",2)="name"
	..set ^INDX2(a,b,"xpath")=a_"."_path
	..for i=2:1 q:'$data(^SYNSCHEMA("STU3","Resource",a,"e",b,"path",i))  set ^INDX2(a,b,"xpath",i)=a_"."_^(i)
	..set ^INDX2(a,b,"type")=type
	..quit
	.quit
	QUIT
	
INDX(resource) ;
	new A,B,C,n,class,code,xpath,type,exp,desc
	
	;set $zt="ERROR^UTILS"
	
	SET (A,B,C)=""
	kill ^INDX(resource)
	set n="search-parameters.json"
	For  Set A=$Order(^Schemas(n,A)) q:A=""  Do
	.For  Set B=$Order(^Schemas(n,A,"entry",B)) q:B=""  do
	..for  set C=$Order(^Schemas(n,A,"entry",B,"resource","base",C)) Q:C=""  do
	...if ^(C)'=resource q
	...set class=^Schemas(n,A,"entry",B,"resource","base",C)
	...set code=^Schemas(n,A,"entry",B,"resource","code")
	...set xpath=$Get(^Schemas(n,A,"entry",B,"resource","xpath"))
	...set type=^Schemas(n,A,"entry",B,"resource","type")
	...;w !,^Schemas(n,A,"entry",B,"resource","expression")
	...set exp=^Schemas(n,A,"entry",B,"resource","expression")
	...set desc=$g(^Schemas(n,A,"entry",B,"resource","description"))
	...;write !,"[",xpath,"]"
	...set xpath=$$XPATH(xpath,class)
	...set exp=$$XPATH(exp,class)
	...Set ^INDX(class,code,"xpath")=xpath
	...Set ^INDX(class,code,"type")=type
	...Set ^INDX(class,code,"exp")=exp
	...Set ^INDX(class,code,"desc")=desc
	...set xpnode=$$CLEANXPATH(xpath)
	...set:xpnode'="" ^XPATH(xpnode,"type")=type
	...set:xpnode'="" ^XPATH(xpnode,"exp")=exp
	...quit
	..quit
	.Quit
	
	Quit

XPATH(xpath,class)
	new i
	for i=1:1:$length(xpath,"|") if $piece(xpath,"|",i)[class set xpath=$p(xpath,"|",i) quit
	Q xpath