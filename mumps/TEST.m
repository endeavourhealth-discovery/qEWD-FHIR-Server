TEST	;
	W !,"Q: "
	read q
	W !,"Resource: "
	read resource
	write !
	
	;set prop=$$GETPROP^INDEX3(q,resource)
	;set type=$$TYPE2^UTILS(prop)
	
	kill ^stuff
	
	set type=$$GETPROP(q,resource)
	
	W !," ** ",type
	
	if type["@" s type=$p(type,"@",2)
	
	for i=$qlength(q):-1:2 do  q:node'?1N
	.set node=$qsubscript(q,i)
	.quit
	
	w !,type
	
	kill ^TYPE($j)
	D BASE(type,node)
	
	s c=$o(^stuff(""),-1)
	W !
	w !,node," is ",type," : ",$get(^TYPE($J,type,node))," : "
	
	i c'="" w ^stuff(c)
	
	w !
	
	zwr:$d(^stuff) ^stuff
	
	;if $data(^SYNSCHEMA("STU3","Base",type)) do
	;.set type2=$get(^SYNSCHEMA("STU3","Base",type,"p",node,"type"))
	;.w !,"type2: [",type2," * ",prop," *",node,"]"
	;.; get the nodes from ^documents that are missing
	;.if type="" do COMPLEX(q,prop,type2)
	;.quit
	;w !,type
	quit

DOC	;
	new a,resource,value,prop,type,ret,g
	kill ^TYPES
	s a="^documents"
	f  s a=$q(@a) q:a=""  do
	.set resource=$qsubscript(a,1)
	.set value=@a
	.; get the last subscript and store against type
	.set prop=$$GETPROP^INDEX3(a,resource)
	.if prop="Reference" quit
	.set type=$$TYPE2^UTILS(prop)
	.i type="" quit
	.w !,a
	.w !,value
	.s g=$$GETLASTQ(a)
	.if '$DATA(^SYNSCHEMA("STU3","Base",type)) w !,">>> ",type r *y quit
	.s ret=$$BASE(type,g)
	.w !,">>> ",ret
	.r *y
	.quit
	quit

GETLASTQ(q)
	n i,sub,get
	set g=""
	for i=$qlength(q):-1:2 do  q:g'=""
	.set sub=$qsubscript(q,i)
	.if sub'?1n.n set g=sub
	.quit
	quit g
	
GETPROP(q,resource)
	new node,i
	set node="",type=""
	for i=$qlength(q):-1:2 do
	.set sub=$qsubscript(q,i)
	.quit:sub?1n.n
	.;set $piece(node,".",(i-2))=sub
	.i $d(^SYNSCHEMA("STU3","Resource",resource,"p",sub)) set type=^SYNSCHEMA("STU3","Resource",resource,"p",sub,"type") w !,type
	.q
	quit type
	
BASE(type,node)
	new a
	set (a,ret)=""
	for  set a=$order(^SYNSCHEMA("STU3","Base",type,"p",a)) quit:a=""  do  quit:ret'=""
	.set type2=^SYNSCHEMA("STU3","Base",type,"p",a,"type")
	.if type2["Reference" quit
	.if type2["Extension" quit
	.set b=$p(type2,"@",2)
	.set ^TYPE($j,type,a)=type2
	.if a=node s ret=type2 quit ; s ^stuff(c)=node_"~"_type_"~"_type2
	.if b'="" set ret=$$BASE(b,node)
	.quit
	quit ret

X	;
	new a,prop
	set (a,prop)=""
	for  set prop=$order(^SYNSCHEMA("STU3","Base",prop)) quit:prop=""  do
	.for  set a=$order(^SYNSCHEMA("STU3","Base",prop,"p",a)) quit:a=""  do
	..set type=$get(^SYNSCHEMA("STU3","Base",prop,"p",a,"type"))
	..if type["@" w !,type
	..q
	.quit
	quit
	
COMPLEX(q,prop,type2)
	new i,type
	w !,"prop: ",prop
	f i=$l(prop,".")+2:1:$qlength(q) do
	.if $qsubscript(q,i)?1n.n quit
	.write !,"> ",$qsubscript(q,i)
	.set p=$qsubscript(q,i)
	.set type=^SYNSCHEMA("STU3","Base",type2,"p",p,"type")
	.quit
	quit
	
VALID(q,resource)
	new prop,type,node
	
	w !,q
	
	set prop=$$GETPROP^INDEX3(q,resource)
	set type=$$TYPE2^UTILS(prop)
	set node=$qsubscript(q,$qlength(q))
	if type'="",$data(^SYNSCHEMA("STU3","Base",type)) do
	.w !,"type2: ",node," * [",type,"]"
	.set type=$get(^SYNSCHEMA("STU3","Base",type,"p",node,"type"))
	.quit
	w !,"[",prop," ",type,"]"
	quit type
	
RUN	;
	new q,r,type
	S q="^documents"
	f  s q=$q(@q) q:q=""  do
	.S r=$qsubscript(q,1)
	.S type=$$VALID(q,r)
	.;w !,q
	.w !,type
	.r *y
	.quit
	quit
	
REVINC	;
	;W !,"NHS NUMBER: "
	;READ NHSNO
	;IF NHSNO="." QUIT
	N id,nhsno
	KILL ^TFND($J)
	set id=""
	for  set id=$order(^documents("Patient",id)) quit:id=""  do
	.set nhsno=$g(^documents("Patient",id,"identifier",0,"value"))
	.i nhsno="" q
	.D FINDREV(nhsno)
	.quit
	QUIT
	
FINDREV(NHSNO)	
	S ID=$ORDER(^docindex3("Patient.identifier",NHSNO_" ",""))
	I ID="" QUIT
	F R="AllergyIntolerance","MedicationStatement" DO
	.S XPATH=$GET(^INDX2(R,"patient","xpath"))
	.S REF="patient/"_ID_" "
	.w !,XPATH," * ",REF
	.S Z=""
	.F  S Z=$O(^docindex3(XPATH,REF,Z)) Q:Z=""  DO
	..I $DATA(^documents(R,Z)) W !,NHSNO," * ",R," * ",Z S ^TFND($J,NHSNO,R)="",^TFND($J,NHSNO)=$get(^TFND($J,NHSNO))+1
	..Q
	.Q
	QUIT