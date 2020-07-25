#!/usr/bin/awk -f
# generate ctags for Markdown
#
# kinds:
#  b block 
#  c header
#  e enum
#  f function
#  i import 
#  m member 
#  r rpc
#  s service
#  v variable 
#
# In order to use mdtags with the vim tagbar plugin, add the following to
# your .vimrc:
#
# let g:tagbar_type_vimwiki = {
#     \ 'ctagsbin' : '~/opt/bin/mdtags',
#     \ 'ctagsargs' : '',
#     \ 'kinds'     : [
#         \ 'b:tag',
#         \ 'c:header',
#     \ ],
#     \ 'sro' : '.',
#     \ 'kind2scope' : {
#         \ 'b' : 'tag',
#         \ 'c' : 'header',
#     \ },
#     \ 'scope2kind' : {
#         \ 'header' : 'c',
#         \ 'tag' : 'b',
#     \ },
#     \ 'sort' : 0,
# \ }
#
function new_tag(name, lnum, line,  kind) {
    gsub(/\\/,"\\\\",line)
    gsub(/\//,"\\/",line)
    print name "\t" FILENAME "\t/^" line "$/;\"\t" kind "\tline:" lnum
}

BEGIN {
    currentfile = "XXXXXXXXXXXXXXXXXXXXXX"
    curlevel = 0
    curheader[curlevel] = "NONE"
}

# reset line count for each file
FILENAME != currentfile {
    linenum = 0
    currentfile = FILENAME
}

# keep track of line number
{
    linenum = linenum+1
    curline = $0
}

function current_header() {
    if (curlevel == 0) {
        return ""
    }
    str = ""
    for(i=0;i<curlevel;i++) {
        str = str ">" curheader[i]
    }
    return "\theader:" str
}

# headers
/^[#]+[[:space:]]/ { 
    match($0, /^(#+)[[:space:]]*(.*)/, a) 
    curlevel = length(a[1]) - 1
    title = a[2]

	# gsub(/[[:space:]]/,"_",title)
    curheader[curlevel] = title

    new_tag(title, linenum, curline, "c\theader:" current_header())

} 

# tags
# format is `#tag`
/#[a-z][^ ]+/ {
    str = $0
    while (match(str, /(^| )#([^ #]*)/, a) ) {
        new_tag(a[2], linenum,  curline, "t\ttag:#tags")
        str = substr(str, RSTART + (RLENGTH ? RLENGTH : 1))
        if (str == "") break
    }
}
