xquery version "3.0";

module namespace search="http://localhost:8080/exist/apps/pessoa/search";

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace config="http://localhost:8080/exist/apps/pessoa/config" at "config.xqm";
import module namespace lists="http://localhost:8080/exist/apps/pessoa/lists" at "lists.xqm";
import module namespace doc="http://localhost:8080/exist/apps/pessoa/doc" at "doc.xqm";
import module namespace helpers="http://localhost:8080/exist/apps/pessoa/helpers" at "helpers.xqm";
import module namespace kwic="http://exist-db.org/xquery/kwic";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace text="http://exist-db.org/xquery/text";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace tei="http://www.tei-c.org/ns/1.0";

(: Ergebniss Volltext Suche - inaktiv :)
declare function search:result-list ($node as node(), $model as map(*), $sel as xs:string) as node()+ {
    if (exists($sel) and $sel = ("text", "head"))
    then
        if (exists($model(concat("result-",$sel))))
        then
        let $term := $model("query") 
            for $hit in $model(concat("result-", $sel))
            let $file-name := root($hit)/util:document-name(.)
            let $title := 
            if(doc(concat("/db/apps/pessoa/data/doc/",$file-name))//tei:sourceDesc/tei:msDesc) 
                then doc(concat("/db/apps/pessoa/data/doc/",$file-name))//tei:msDesc/tei:msIdentifier/tei:idno[1]/data(.)
                else doc(concat("/db/apps/pessoa/data/doc/",$file-name))//tei:biblStruct/tei:analytic/tei:title[1]/data(.)
            let $expanded := kwic:expand($hit)
        return if($sel != "head")
            then 
            <li>
            <a href="data/doc/{concat(substring-before($file-name, ".xml"),'?term=',$model("query"), '&amp;file=', $file-name)}">{$title}</a>
            {kwic:get-summary($expanded,($expanded//exist:match)[1], <config width ="40"/>)}
            </li>
            else 
            <li> 
            <a href="data/doc/{concat(substring-before($file-name, ".xml"),'?term=',$model("query"), '&amp;file=', $file-name)}">{$title}</a>
            {kwic:get-summary($expanded,($expanded//exist:match)[1], <config width ="0" />)}</li>
        else <p> Keine Treffer </p>
        else $sel
};
(:  Profi Suche :)

declare %templates:wrap function search:profisearch($node as node(), $model as map(*), $term as xs:string?) as map(*) {
        (: Erstellung der Kollektion, sortiert ob "Publiziert" oder "Nicht Publiziert" :)
     (:   if(exists($term)) then :)
        let $db := search:set_db()
        
        (: Unterscheidung nach den Sprachen, ob "Und" oder "ODER" :)
        let $r_lang := if(search:get-parameters("lang_ao") = "or") 
                       then search:lang_or($db)
                       else search:lang_and($db)
                       
        (: Sortierung nach Genre :)
       let $r_genre := if(search:get-parameters("genre")!="") then search:search_range("genre",$r_lang)
                        else()                      
        (:Suche nach "Erwähnten" Rollen:)
        let $r_mention := if(search:get-parameters("notional")="mentioned") then search:author_build($r_lang)
                        else ()
        let $r_real := if(search:get-parameters("notional") ="real") then search:search_range("person",$r_lang)
                        else ()
     
        (: Datumssuche :)
        let $r_date := if(search:get-parameters("before") != "" or search:get-parameters("after") != "") then search:date_build($r_lang)
                        else ()
        (: Volltext Suche :)                
        let $r_head := if(search:get-parameters("search")="simple" and $term != "") then (collection("/db/apps/pessoa/data/doc")//tei:msItemStruct[ft:query(.,search:get-parameters("term"))] , collection("/db/apps/pessoa/data/pub")//tei:teiHeader[ft:query(.,$term)])
                        else if($term != "") then (search:full_text($r_lang,"tei:msItemStruct") , search:full_text($r_lang,"tei:teiHeader"))
                        else()
        let $r_text := if(search:get-parameters("search")="simple" and $term != "") then ( collection("/db/apps/pessoa/data/doc")//tei:text[ft:query(.,search:get-parameters("term"))] , collection("/db/apps/pessoa/data/pub")//tei:text[ft:query(.,$term)] )
                        else if ($term != "")then search:full_text($r_lang,"tei:text")
                        else()
        
        let $r_all := ($r_lang,$r_genre,$r_mention,$r_real,$r_date,$r_head,$r_text)
       
        return map{
            "r_all"     := $r_all,
            "r_lang"    := $r_lang, 
            "r_genre"   := $r_genre,
            "r_mention" := $r_mention,
            "r_date"    := $r_date,
            "r_real"    := $r_real,
            "r_head"    := $r_head,
            "r_text"    := $r_text
        }
      (:  else map{
            "r_all"     := (),
            "r_lang"    := (), 
            "r_genre"   := (),
            "r_mention" := (),
            "r_date"    := (),
            "r_real"    := (),
            "r_head"    := (),
            "r_text"    := ()
           }
           :)
};




declare function search:set_db() as xs:string+ {
        let $result :=    if(search:get-parameters("release") = "non_public")  then "/db/apps/pessoa/data/doc"
                             else if(search:get-parameters("release") = "public" ) then "/db/apps/pessoa/data/pub"
                             else ("/db/apps/pessoa/data/doc","/db/apps/pessoa/data/pub")
                   return $result
};

(: Funtkion um die Parameter rauszufiltern:)
declare function search:get-parameters($key as xs:string) as xs:string* {
    for $hit in request:get-parameter-names()
        return if($hit=$key) then request:get-parameter($hit,'')
                else ()
};

(: Volltext Suche Erweitert :)
declare function search:full_text($db as node()*, $struct as xs:string) as node()* {
    let $query := <query><bool><term>(search:get-parameters("term"))</term></bool></query>
    let $search_func :=  concat("//",$struct,"[ft:query(.,",$query,")]")
    let $search_build := concat("$db",$search_func)
    let $result := util:eval($search_build)
    return $result
};
(: ODER FUNTKION : Filtert die Sprache :) 
declare function search:lang_or($db as xs:string+) as node()*{
    for $match in $db
        let $result := if(search:get-parameters("release") != "either") then  search:lang_filter_or($match,"")
                      else if(search:get-parameters("release") = "either") then 
                            if($match = "/db/apps/pessoa/data/doc") then search:lang_filter_or($match,"non_public")
                            else if ($match = "/db/apps/pessoa/data/pub") then search:lang_filter_or($match, "public")
                            else()
                       else ()
        return $result
};

declare function search:lang_filter_or($db as xs:string, $step as xs:string?) as node()* {
    if(search:get-parameters("release")="non_public" or $step = "non_public") then
        for $hit in search:get-parameters("lang")
            let $para := ("mainLang","otherLang")
            for $match in $para
                let $search_terms := concat('("',$match,'"),"',$hit,'"')
                let $search_funk := concat("//range:field-contains(",$search_terms,")")
                let $search_build := concat("collection($db)",$search_funk)
                let $result :=  util:eval($search_build) 
            return $result
        else if (search:get-parameters("release")="public" or $step = "public") then 
            for $hit in search:get-parameters("lang")
                let $search_terms := concat('("lang"),"',$hit,'"')
                let $search_funk := concat("//range:field-contains(",$search_terms,")")
                let $search_build := concat("collection($db)",$search_funk)
                let $result :=  util:eval($search_build) 
            return $result
        else ()
};

(: START UND FUNKTION : Filtert die Sprache :)

declare function search:lang_and($db as xs:string+) as node()* {
    for $match in $db 
        let $result := if(search:get-parameters("release") != "either") then  search:lang_filter_and($match,"")
                      else if(search:get-parameters("release") = "either") then 
                            if($match = "/db/apps/pessoa/data/doc") then search:lang_filter_and($match,"non_public")
                            else if ($match = "/db/apps/pessoa/data/pub") then search:lang_filter_and($match, "public")
                            else()
                       else ()
                       (:(search:lang_filter_and($match,"non_public"),search:lang_filter_and($match, "public")):)
        return $result
};

declare function search:lang_filter_and($db as xs:string, $step as xs:string?) as node()* {
        if(search:get-parameters("release")="non_public" or $step = "non_public") then
        for $match in search:lang_build_para("lang")
        let $build_funk := concat("//range:field-contains(",$match,")")
        let $build_search := concat("collection($db)",$build_funk) 
        let $result := util:eval($build_search)   
        return $result
        else if (search:get-parameters("release")="public" or $step = "public") then 
        let $result := ()
        return $result
        else ()
};

declare function search:lang_db() as xs:string* {
    for $search in search:lang_build_para("lang")
        let $build_funk := concat("//range:field-contains(",$search,")")
        let $build_search := concat("collection($db)",$build_funk) 
        let $result := $build_search
        return $result
};

declare function search:lang_build_para ($para as xs:string) as xs:string* {
    for $hit in search:get-parameters($para)
     (: let $parameters :=  search:get-parameters($para):)
        let $result := concat('("',
        string-join(search:lang_build_para_ex(search:get-parameters($para),$hit),
        '","'),'"),"',
        string-join(search:get-parameters("lang"),'","'),'"')
        return $result
};

declare function search:lang_build_para_ex($para as xs:string+, $hit as xs:string) as xs:string* {
        for $other in $para
            let $result := if($other = $hit) then "mainLang" else "otherLang"
            return $result
};
(: Sprach Filter END:)

(: Query Suche :)
declare function search:search_query($para as xs:string, $db as node()*) as node()* {
    for $hit in search:get-parameters($para)
        let $hit := if($para = "genre") then replace($hit, "_", " ")
                    else $hit
        
            let $query := <query><bool><term occur="must">{$hit}</term></bool></query>
            let $search_funk := "[ft:query(.,$query)]"
            let $search_build := concat("collection($db)//tei:msItemStruct",$search_funk) 
            let $result := util:eval($search_build)
            return $result
};
(: Range Suche :)
declare function search:search_range($para as xs:string, $db as node()*) as node()* {
    for $hit in search:get-parameters($para)    
     (:   let $para := if($para = "person")then  "author" else () :)
        let $search_terms := concat('("',$para,'"),"',$hit,'"')
        let $search_funk := concat("//range:field-eq(",$search_terms,")")
        let $search_build := concat("$db",$search_funk)
        let $result := util:eval($search_build)
        return $result
};

(: Suche nach den Autoren und der Rollen :)
declare function search:author_build($db as node()*) as node()* {
        for $person in search:get-parameters("person")
           for $role in search:get-parameters("role")
                let $merge := concat('("person","role"),','"',$person,'","',$role,'"')
                let $build_range :=concat("//range:field-eq(",$merge,")")
                let $build_search := concat("$db",$build_range)
                let $result := util:eval($build_search)
           return $result
};

(: Suche nach Datumsbereich :)
declare function search:date_build($db as node()*) as node()* {
     let $start := if(search:get-parameters("after") ="") then xs:integer("1900") else xs:integer(search:get-parameters("after"))
     let $end := if( search:get-parameters("before") = "") then xs:integer("1935") else xs:integer(search:get-parameters("before"))
     let $paras := ("date","date_when","date_notBefore","date_notAfter","date_from","date_to")
     for $date in ($start to $end)
        for $para in $paras
         let $result := search:date_search($db,$para,$date)
         return $result
     
};

declare function search:date_search($db as node()*,$para as xs:string,$date as xs:string)as node()* {
        let $search_terms := concat('("',$para,'"),"',$date,'"')
        let $search_funk := concat("//range:field-contains(",$search_terms,")")
        let $search_build := concat("$db",$search_funk)
        let $result := util:eval($search_build)
        return $result
};

(: Profi Result :)
declare function search:profiresult($node as node(), $model as map(*), $sel as xs:string) as node()+ {
   if(exists($sel) and $sel=("lang","genre","mention","date","real","all","head","text"))
   then
   if(exists($model(concat("r_",$sel)))) 
    then 
        for $hit in $model(concat("r_",$sel))
        (:
        return <p> Exist, {$model(concat("r_",$sel))}</p>
        else <p>Dos Not Exist </p>
        :)
        let $file-name := root($hit)/util:document-name(.)            
        order by $file-name
        return <p>Exist,{$file-name}</p>            
        else <p> Dos Not exist,{$model(concat("r_",$sel))}</p>
        
        (:
        return <p>Exist,{$model("profi_result"),$file-name}</p>            
        else <p> Dos Not exist,{$model("profi_result")}</p>
        :)
        else <p>Error</p>
};      

declare function search:new_profiresult($node as node(), $model as map(*), $sel as xs:string) as node()+ {
let $para := ("lang","genre","mention","date","real","head","text")
for $name in $para
    for $hit in $model(concat("r_",$name))
        
        let $file_name := root($hit)/util:document-name(.)
        let $expanded := kwic:expand($hit)
                    
        order by $file_name
        return if(substring-after($file_name,"BNP") != "" or substring-after($file_name,"X"))
                    then <li><a href="data/doc/{concat(substring-before($file_name, ".xml"),'?file=', $file_name)}"></a>
                        {kwic:get-summary($expanded,($expanded//exist:match)[1], <config width ="40"/>)}</li>
                        else <p>Nothin, {$file_name}</p>
        
(: if(exists($sel) and $sel = "all")
then
    if(exists($model(concat("r_",$sel))))
    then
        for $hit in $model(concat("r_",$sel))
            let $file_name := root($hit)/util:document-name(.)
           let $result :=  if($file_name != $hit) then <p> Ebene 3 Ich lebe </p>(:search:filter_result($model(concat("r_",$sel)),$file_name,concat("r_",$sel)):)
                            else <p>3 Ebene</p>
            return $result
            else <p>2 Ebene</p>
        else <p>1 Ebene</p>
        :)

};

declare function search:filter_result($hit as element(), $term as xs:string*) as node()+ {
        let $file_name := root($hit)/util:document-name(.)
     (:   let $title := if(substring-before($fíle_name,"BNP") or substring-before($file_name,"X"))
                      then doc(concat("/db/apps/pessoa/data/doc/",$file-name))//tei:msDesc/tei:msIdentifier/tei:idno[1]/data(.)
                      else doc(concat("/db/apps/pessoa/data/doc/",$file-name))//tei:biblStruct/tei:analytic/tei:title[1]/data(.)
                      :)
         let $expanded := kwic:expand($hit)
         return  if(substring-after($file_name,"BNP") != "" or substring-after($file_name,"X"))
                    then <li><a href="data/doc/{concat(substring-before($file_name, ".xml"),'?file=', $file_name)}"></a>
                        {kwic:get-summary($expanded,($expanded//exist:match)[1], <config width ="40"/>)}</li>
                        else <p>Nothin, {$file_name}</p>
                      
        
};

(: Ende der Neuen Funktionen :)

(: Nur zum abgleichen

////
then <li><a href="data/doc/{concat(substring-before($file_name, ".xml"),'?term=',$term, '&amp;file=', $file_name)}"></a>
                        {kwic:get-summary($expanded,($expanded//exist:match)[1], <config width ="40"/>)}</li>
                        else <p>Nothin, {$file_name}</p>
                        
////


declare %templates:wrap function search:search( $node as node(), $model as map(*), $term as xs:string?) as map(*) {
(:
for $m in collection("/db/apps/pessoa/data/doc")//tei:origDate[ft:query(.,$q)]
order by ft:score($m) descending
:)
(: let $term := request:get-parameter('term', "") :)
if(exists($term) and $term !=" ")
then
let $term := search:get-parameters("term")
let $result-text := collection("/db/apps/pessoa/data/doc")//tei:text[ft:query(.,$term)]
let $result-head := collection("/db/apps/pessoa/data/doc")//tei:msItemStruct[ft:query(.,$term)]
let $result := ($result-text, $result-head)
return map{
"result" := $result,
"result-text" := $result-text,
"result-head" := $result-head,
"query" := $term
}
else map{
"resilt-text":=(),
"result-head":=(),
"query" := '"..."'
}
};

declare function search:result-list ($node as node(), $model as map(*), $sel as xs:string) as node()+ {
    if (exists($sel) and $sel = ("text", "head"))
    then
        if (exists($model(concat("result-",$sel))))
        then
        let $term := $model("query") 
            for $hit in $model(concat("result-", $sel))
            let $file-name := root($hit)/util:document-name(.)
            let $title := 
            if(doc(concat("/db/apps/pessoa/data/doc/",$file-name))//tei:sourceDesc/tei:msDesc) 
                then doc(concat("/db/apps/pessoa/data/doc/",$file-name))//tei:msDesc/tei:msIdentifier/tei:idno[1]/data(.)
                else doc(concat("/db/apps/pessoa/data/doc/",$file-name))//tei:biblStruct/tei:analytic/tei:title[1]/data(.)
            let $expanded := kwic:expand($hit)
        return if($sel != "head")
            then 
            <li>
            <a href="data/doc/{concat(substring-before($file-name, ".xml"),'?term=',$model("query"), '&amp;file=', $file-name)}">{$title}</a>
            {kwic:get-summary($expanded,($expanded//exist:match)[1], <config width ="40"/>)}
            </li>
            else 
            <li> 
            <a href="data/doc/{concat(substring-before($file-name, ".xml"),'?term=',$model("query"), '&amp;file=', $file-name)}">{$title}</a>
            {kwic:get-summary($expanded,($expanded//exist:match)[1], <config width ="0" />)}</li>
        else <p> Keine Treffer </p>
        else $sel
};

:)
declare function search:highlight-matches($node as node(), $model as map(*), $term as xs:string?, $sel as xs:string, $file as xs:string?) as node() {
if($term and $file and $sel and $sel="text","head","lang") 
    then
        let $result := if ($sel = "text")
        then doc(concat("/db/apps/pessoa/data/doc/",$file))//tei:text[ft:query(.,$term)]
        else ()
        let $css := doc("/db/apps/pessoa/highlight-matches.xsl")
        let $exp := if (exists($result)) then kwic:expand($result[1]) else ()
        let $exptrans := if (exists($exp))
                         then transform:transform($exp, $css, ())
                         else ()
        return
            if (exists($exptrans))
            then $exptrans
            else $node
    else $node
};
