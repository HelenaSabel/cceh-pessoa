/*"autores","documentos","publicacoes","genero","cronologia","bibliografia","projeto" */
$(document).ready(function(){
            $("ul#navi_elements li.mainNavTab").click(function() {
                if(!$(this).hasClass("active")) {
                    $("ul#navi_elements li.active").removeClass("active");
                    $(this).addClass("active");
                    var id1 = $(this).attr('id');
                    $("div.active").css("display","none");
                    $("div.active").removeClass("active");             
                    $("div#nav_"+id1.substring(8)).addClass("active");
                    $("div#nav_"+id1.substring(8)).css("display","block");
                    $("div#nav_"+id1.substring(8)+" li").click(function() {
                        if(!$(this).hasClass("active")) {
                            $("div#nav_"+id1.substring(8)+" li.active").removeClass("active");
                            $(this).addClass("active");
                            var id2 = $(this).attr('id');
                            var clas = $(this).attr('class');
                            var clas2 = clas.substring(0,clas.search("tab"));
                            if(id2.search("navtab") != -1) {
                                    $("div#"+clas2+"sub div.active").css("display","none");
                                    $("div#"+clas2+"sub div.active").removeClass("active");   
                                    $("div#nav"+id2.substring(6)).addClass("active");
                                    $("div#nav"+id2.substring(6)).css("display","block");
                                    $("div#"+clas2+"sub").addClass("active");
                                    $("div#"+clas2+"sub").css("display","block");             
                                    $("div#nav"+id2.substring(6)+" li.nav_cronologia_sub_tab").click(function() { 
                                        if(!$(this).hasClass("active")) {
                                            $("div#nav"+id2.substring(6)+" li.nav_cronologia_sub_tab.active").removeClass("active");
                                            $(this).addClass("active");
                                            var id = $(this).attr('id');
                                            var clase = $(this).attr('class');
                                            var clase2 = clase.substring(0,clase.search("tab"));
                                            $("div#"+clase2+"ext div.active").css("display","none");
                                            $("div#"+clase2+"ext div.active").removeClass("active");
                                            $("div#"+clase2+"ext").css("display","block");
                                            $("div#"+clase2+"ext").addClass("active");
                                            $("div#"+clase2+"ext_"+id.substring(11)).addClass("active");
                                            $("div#"+clase2+"ext_"+id.substring(11)).css("display","block");
                                        }
                                    });
                            }
                          }
                    });
                }
                else if ($(this).hasClass("active")) {
                    $("div#navi").children("div.navbar").css("display","none");
                    $("div#navi").children("div.navbar").children("div").css("display","none");
                    $("div#navi .active").removeClass("active");
                }
        });
        });

$(document).ready(function(){ 
    /*$("div#searchbox").hide();*/
    $("a#search_button").click(function() {
           
           if(!$(this).hasClass("active")) {
               $(this).addClass("active");
               $("div#searchbox").show();
            }
           else {
               $(this).removeClass("active");
                $("div#searchbox").hide();
             }
           });
});


 
 
 function DocHide() {
            
           var path = $(location).attr('href');
           
           if(path.search("/en/") != -1) {
            var name =   "Note";
           }
           else if (path.search("/pt/") != -1)  {
               var name ="Nota";
           }
           else {
               var name ="Nota";
           }
        $("div.editorial-note").before("<span class='nota' id='nota_top'>"+name+"</span>");
        $("div.editorial-note").after("<span class='nota' id='nota_bottom'>"+name+"</span>");

         $("span.nota").click(function() {
           
           if(!$(this).hasClass("active")) {
               $("#nota_bottom").addClass("active");
               $("#nota_top").addClass("active");
               $(".editorial-note").show("slow");
               $("#nota_bottom").show();
            }
           else {
               $("#nota_bottom").removeClass("active");
               $("#nota_top").removeClass("active");
                $(".editorial-note").hide("slow");
                $("#nota_bottom").hide();


             }
           });
           
           
            
 }
 
 
 function draw(w, h) {
 
 /*
  if(is.firefox() == true) {
      var  ctx1= document.getElementsByClassName("delSpan");
        var canvas = ctx1.getContext("2d");
        var  ctx2= document.getElementsByClassName("verticalLine");
        var canvas2 = ctx2.getContext("2d");
        var  ctx3= document.getElementsByClassName("circled");
        var canvas3 = ctx3.getContext("2d");
  } 
  else {
      var canvas = document.getCSSCanvasContext("2d", "lines", w, h); 
      var canvas2 = document.getCSSCanvasContext("2d", "verticalLine", w, h);
      var canvas3 = document.getCSSCanvasContext("2d", "circle", w, h);
  }
 */
            var canvas = document.getCSSCanvasContext("2d", "lines", w, h); 
      var canvas2 = document.getCSSCanvasContext("2d", "verticalLine", w, h);
      var canvas3 = document.getCSSCanvasContext("2d", "circle", w, h);
            canvas.strokeStyle = "rgb(0,0,0)";
            canvas.beginPath();
            canvas.moveTo( 0,0);
            canvas.lineTo( w, h );
            canvas.stroke();
            
            
            canvas2.strokeStyle = "rgb(0,0,0)";
            canvas2.beginPath();
            canvas2.moveTo( 0,0);
            canvas2.lineTo( 10,60 );
            canvas2.stroke();
            
            
            canvas3.strokeStyle = "rgb(0,0,0)";
            canvas3.beginPath();
            canvas3.arc(12,12,12,0,2*Math.PI);
            canvas3.stroke();
            };
 

function printContent() {

            var id = $("div#text-div").children("ul").children("li.active").children("div").attr("id");
            var printContents = document.getElementById(id).innerHTML;
                 var originalContents = document.body.innerHTML;
                document.body.innerHTML = printContents;
                window.print();
                document.body.innerHTML = originalContents;
              

/*
                var printContents = $("div.text").html;
               var printContents = document.getElementsByClassName("text").innerHTML;
                var originalContents = document.body.innerHTML;
                document.body.innerHTML = printContents;
              window.print();
                document.body.innerHTML = originalContents;
            
            */
            }; 
 
 function SearchHide() {
    $("div.tab").click(function() {
       var id1 = $(this).attr("id");
           var id2 = id1.substring(3)
           
           if(!$(this).hasClass("active")) {
               $(this).addClass("active");
               $("div#se_"+id2).show();
            }
           else {
               $(this).removeClass("active");
                $("div#se_"+id2).hide();
             }
           });
     
 };
 
 
 
 /*############## Obras Control ############*/
 
 function ObrasHide() {
           $("span.ObLink").click(function() {
           var id1 = $(this).attr("id");
           var id2 = id1.substring(5)
           if(!$(this).hasClass("active")) {
               $(this).addClass("active");
               $("#"+id2).show("slow");
            }
           else {
               $(this).removeClass("active");
                $("#"+id2).hide("slow");
             }
           });
};


function ObrasControl() {
        $("div.Obras-SubNav").next("div").css("display","block");
        $("div#Obras-DocLinkList").next("div").css("display","block");
        
        $("div.Obras-WorkName").click(function() {
            $(this).nextAll("div").toggle("blind","slow");
            
            if(!$(this).hasClass("selected")) {
                $(this).addClass("selected");
            }
            else {
                $(this).removeClass("selected");
            }
        });
        
        $("div.Obras-SubNav").click(function() {
            $(this).next("div").children("div").toggle("blind","slow");
            
            if(!$(this).hasClass("selected")) {
                $(this).addClass("selected");
            }
            else {
                $(this).removeClass("selected");
            }
           
        });
        $("div#Obras-DocLinkList").click(function() {
            $(this).next("div").children("div").toggle("blind","slow");
            
            if(!$(this).hasClass("selected")) {
                $(this).addClass("selected");
            }
            else {
                $(this).removeClass("selected");
            }
        });
        
    };

  
    
    
