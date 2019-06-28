EVERYTHING ;

FINDREV(id)
	new r,xpath,ref,z,n
	set n=1
	kill ^temp($j)
	if id="" quit 1
	if $data(^documents("Patient",id)) S ^temp($j,"Ids",n)=id_"|Patient",n=$i(n)
	set r=""
	for  set r=$order(^INDX2(r)) quit:r=""  do
	.S xpath=$GET(^INDX2(r,"patient","xpath"))
	.if xpath="" quit
	.set ref="patient/"_id_" "
	.set z=""
	.for  set z=$O(^docindex3(xpath,ref,z)) quit:z=""  do
	..if $data(^documents(r,z)) W !,r," * ",z set ^temp($j,"Ids",n)=z_"|"_r,n=n+1
	..quit
	.quit
	set ^temp($j,"howmany")=$order(^temp($j,"Ids",""),-1)
	set ^temp($j,"baseurl")=$get(^BASE,"http://localhost:8080/fhir/STU3/")
	quit
	
KILL(id)	; kills all the resources for a patient (pass in the patient resource)
	new n,z,resource,rec
	; Patient resource?
	if '$d(^documents("Patient",id)) W !,"id not a Patient resource?" quit
	D FINDREV(id)
	set n=""
	for  set n=$order(^temp($j,"Ids",n)) quit:n=""  do
	.set rec=^(n)
	.set z=$p(rec,"|",1),resource=$p(rec,"|",2)
	.set ret=$$KILL^KILL3(resource,z)
	.quit
	quit