
def input param table-handle tt.
def input param c-dump-file as char.
def input param c-area      as char.
def input param c-area-idx  as char.
def input param c-out-file  as char.


def var hb     as handle no-undo.
def var hf     as handle no-undo.
def var ifield as int no-undo.
def var vindex as char no-undo.
def var i-cont-idx as int. 
def var i-cont as int. 


def var h-buffer            as handle.
def var hf2                 as handle.
def var vindex2             as char no-undo.
def var l-cria-idx          as log.

hb = tt:default-buffer-handle.

output to value(c-out-file) /* no-convert*/ .

def var c-table-name            as char.
assign c-table-name = hb:name.

if substr(c-table-name, 1, 3) = "tt-" or 
   substr(c-table-name, 1, 3) = "tt_" then do:
    assign c-table-name = substr(c-table-name, 4).    
end.


create buffer h-buffer for table c-table-name no-error.
/* se nao existe a tabela, cria */
if not valid-handle( h-buffer ) then do:
    put unformatted substitute( "ADD TABLE &1", quoter(c-table-name)) skip.
    put unformatted 
       substitute(
           "  AREA &1",
               quoter(c-area)
               ) skip.

    put unformatted 
       substitute(
           "  DUMP-NAME &1",
               quoter(c-dump-file)
               ) skip.

    put unformatted skip (1).
end.




do ifield = 1 to hb:num-fields:

    hf = hb:buffer-field( ifield ).
   
    /* verifica se ja existe o campo, em caso de edicao */
    if valid-handle( h-buffer ) then do:        
        hf2 = h-buffer:buffer-field(hf:name) no-error.
        if valid-handle(hf2) then do:          
            
            next.    
        end.         
       
    end.  
    

    put unformatted
      substitute( 
         "ADD FIELD &1 OF &2 AS &3", 
         quoter( hf:name ), 
         quoter( c-table-name ), 
         hf:data-type 
      ) skip.

   

    put unformatted 
       substitute(
           "  FORMAT &1",
               quoter(hf:format)
               ) skip.

    put unformatted 
        substitute (
            "  LABEL &1",
                quoter( hf:label )
                ) skip.

    if hf:help begins "view-as" then do:
        put unformatted 
            substitute (
                "  VIEW-AS &1",
                    quoter( hf:help )
                    ) skip.
    end.

    if hf:data-type = "decimal" then do:

        if hf:decimals = 0 then do:
            put unformatted 
                substitute (
                "  DECIMALS &1",
                    4
                    ) skip.
        end.
        else do:
            put unformatted 
                substitute (
                    "  DECIMALS &1",
                        hf:decimals
                        ) skip.
        end.
    end.


    if ifield < hb:num-fields then put unformatted skip (1).   

end. 

put unformatted skip(1).


assign vindex = hb:index-information(1).
if valid-handle( h-buffer ) then do:        
    if hb:index-information(1) <> h-buffer:index-information(1) then do:
        assign l-cria-idx = yes.
    end.
        
end. 
else do:
    assign l-cria-idx = yes.
end.

/*=== INDEX CREATION ===*/
if l-cria-idx then do:     

    if lookup("default",vindex) <= 0 then do:  

        assign i-cont-idx = 1.
           
        do while vindex <> ?.
            put unformatted(
                substitute(
                    "ADD INDEX &1 ON &2",
                        quoter(entry(01,vindex,",")),
                        quoter( c-table-name ))) skip.
        
            put unformatted 
               substitute(
                   "  AREA &1",
                       quoter(c-area-idx)
                       ) skip.
        
            if entry(02,vindex,",") = "1" 
            then put unformatted "  UNIQUE" skip.
        
            if entry(03,vindex,",") = "1" 
            then put unformatted "  PRIMARY" skip.
        
            do i-cont = 5 to 30 by 2:
                if num-entries(vindex,",") > i-cont 
                then put unformatted "  INDEX-FIELD " entry(i-cont,vindex,",") " " (if entry(i-cont + 1,vindex,",") = "0" then "ASCENDING" else "DESCENDING") skip.
            end.   

            put unformatted skip(1).

            ASSIGN i-cont-idx = i-cont-idx + 1.
            assign vindex = hb:index-information(i-cont-idx).

        end.
    end.
            

end.
/*=== INDEX CREATION ===*/



put unformatted 
    "." skip
    "PSC" skip
    "cpstream=ibm850" skip 
    "." .

put unformatted skip(1).

output close.
