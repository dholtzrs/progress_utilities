/* definitions */
def temp-table tt-col no-undo
    field brwshdl       as handle
    field colhdl        as handle
    field colname       as char
    field colwidth      as dec
    field colformat     as char
    field coldattyp     as char
    field collabel      as char
    index brwscol is primary unique 
            brwshdl colhdl.

/* local-initialize*/
def var h-column        as handle.
h-column = <browse-name>:first-column.
do while valid-handle(h-column):        
    create tt-col.
    assign tt-col.brwshdl    = <browse-name>:handle
           tt-col.colhdl     = h-column
           tt-col.colname    = h-column:name
           tt-col.colwidth   = h-column:width
           tt-col.colformat  = h-column:format
           tt-col.coldattyp  = h-column:data-type
           tt-col.collabel   = h-column:label.		   
		   
    h-column = h-column:next-column.
	
end.

/* browse row-display */
if <condition> then do:
	for each tt-col no-lock:
		assign tt-col.colhdl:bgcolor = 14.
	end.
end.
else do:
	for each tt-col no-lock:
		assign tt-col.colhdl:bgcolor = 15.
	end.
end.
