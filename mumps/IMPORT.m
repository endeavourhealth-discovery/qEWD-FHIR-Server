IMPORT(sd) ;
 K ^schema
 ;s sd="/root/.yottadb/r/schema.glb"
 close sd
 open sd:(readonly:exception="do BADOPEN")
 use sd:exception="goto EOF"
 for  use sd read x use $principal write x,! X x

EOF;
 if '$zeof zmessage +$zstatus
 close sd
 quit