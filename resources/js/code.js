function hide(id) {
                        if (document.getElementById(id).style.display == 'none') {
                            document.getElementById(id).style.display ="block";
                            }
                        else {
                            document.getElementById(id).style.display ="none";
                            }
                        };
/*"autores","documentos","publicacoes","genero","cronologia","bibliografia","projeto" */

function u_nav(navID) {
       
       var IDs = new Array ("nav_autores","nav_bibliografia","nav_documentos","nav_documentos_sub","nav_documentos_sub_1","nav_documentos_sub_2","nav_documentos_sub_3","nav_documentos_sub_4","nav_documentos_sub_5","nav_documentos_sub_6","nav_documentos_sub_7","nav_documentos_sub_8","nav_documentos_sub_9","nav_publicacoes","nav_genero","nav_cronologia","nav_cronologia_sub","nav_cronologia_sub_0","nav_cronologia_sub_1","nav_cronologia_sub_2","nav_cronologia_sub_3","nav_projeto");
        
       for (var i = 0; i<IDs.length; i++) {

        if (document.getElementById(navID).style.display == "none" && IDs[i].indexOf(navID) != -1) {
            if (navID.indexOf("nav_documentos_sub_") != -1 || navID.indexOf("nav_cronologia_sub_") != -1) {
                document.getElementById(navID).style.display = "inline-block";
            }
            else {
                document.getElementById(navID).style.display = "block"; 
             }
             if (navID.indexOf("nav_documentos") != -1) {
                        document.getElementById("nav_documentos").style.display = "block";
                        if(navID.indexOf("nav_documentos_sub") != -1) {
                            document.getElementById("nav_documentos_sub").style.display = "block";
                        }
                }
                else if (navID.indexOf("nav_cronologia") != -1) {
                    document.getElementById("nav_cronologia").style.display = "block";
                    if(navID.indexOf("nav_cronologia_sub") != -1) {
                        document.getElementById("nav_cronologia_sub").style.display = "block";
                        }
                }
        }
        else {
            document.getElementById(IDs[i]).style.display = "none";
            }
       }
    };


 