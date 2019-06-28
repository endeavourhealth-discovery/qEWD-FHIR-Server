GFIND ;
	n glb,str,query
	r "which global? ",glb,!
	r "string? ",str,!
	f  s glb=$q(@glb) q:glb=""  d
	.i glb[str!(@glb[str) w !,glb,"=",@glb
	.q
	q
	
FIND(glb,str)
	new cnt,nodes
	kill ^temp($j)
	set cnt=1
	for  set glb=$query(@glb) q:glb=""  do  q:cnt>500
	.set nodes=$TR(glb,"""","'")
	.if glb[str!(@glb[str) set ^temp($j,cnt)=nodes_"="_@glb,cnt=cnt+1
	.quit
	quit 1
	
KILL(resource,id)
	new ret
	k ^temp($j)
	if $get(id)="" set ^temp($j,1)="error: id is not defined!" quit 1
	if $get(resource)="" set ^temp($j,1)="error: resource is not defined!" quit 1
	if '$d(^documents(resource,id)) set ^temp($j,1)="resource does not exist?" quit 1
	set ret=$$KILL^KILL3(resource,id)
	set ^temp($j,1)=resource_":"_id_" removed ok"
	quit 1