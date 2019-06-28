REFS	;
CHECK(p)	; check references
	New json,l,q,ref,cnt,resource,id,json,output,err
	
	set $ECODE=""
	set $ETRAP="GOTO ET^UTILS"
	
	; force an error to test error trap
	;w 1/0
	
	kill ^temp($j)
	Set (l,json)=""
	For  Set l=$Order(^RAWJSON(p,l)) Quit:l=""  Set json=json_^(l)
	Do DECODE^VPRJSON($NAME(json),$NAME(output),$NAME(err))
	Set q="output",cnt=1
	For  Set q=$q(@q) q:q=""  Do
	.If q["reference" Do
	..Set ref=@q
	..Set resource=$Piece(ref,"/"),id=$Piece(ref,"/",2)
	..If id="" set ^temp($Job,"missing",cnt)="id is null",cnt=cnt+1 quit
	..If resource="" set ^temp($Job,"missing",cnt)="resource is null",cnt=cnt+1 quit
	..If '$Data(^documents(resource,id)) Set ^temp($Job,"missing",cnt)="Missing "_ref,cnt=cnt+1
	..Quit
	.Quit
	
	set:'$d(^temp($j)) ^temp($j,1)="ok"
	
	Quit 1