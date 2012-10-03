-------------------------------------------------------------------------  
--  Visualizador de Ficheros PostScript                                --
-------------------------------------------------------------------------                              
--  010248; Roberto López Masiá; roberto.lopez.masia@hotmail.com       --
--  040289; Andres Gómez Fasbender; fass_centauri@hotmail.com          --
--  050007; Ángel Alférez Aroca; alferez.aroca@gmail.com               --
-------------------------------------------------------------------------


GENERIC
   TYPE Tipo_Elemento IS PRIVATE; 

PACKAGE Iteradores IS

   TYPE Iterador IS LIMITED PRIVATE; 

   PROCEDURE Crear_Iterador (
         I :    OUT Iterador ); 

   FUNCTION Es_Vacio (
         I : IN     Iterador ) 
     RETURN Boolean; 

   PROCEDURE Insertar_Dato (
         E : IN     Tipo_Elemento; 
         I : IN OUT Iterador       ); 

   PROCEDURE Iniciar (
         I : IN OUT Iterador ); 

   FUNCTION Hay_Siguiente (
         I : Iterador ) 
     RETURN Boolean; 

   PROCEDURE Siguiente (
         I : IN OUT Iterador ); 

   FUNCTION Dato_Actual (
         I : Iterador ) 
     RETURN Tipo_Elemento; 

   PROCEDURE Destruir (
         I : IN OUT Iterador ); 

   PROCEDURE Asignar (
         A :    OUT Iterador; 
         B : IN     Iterador  ); 

PRIVATE
   TYPE Nodo; 
   TYPE Cadena IS ACCESS Nodo; 
   TYPE Iterador IS 
      RECORD 
         Actual  : Cadena;  
         Primero : Cadena;  
         Ultimo  : Cadena;  
      END RECORD; 
   TYPE Nodo IS 
      RECORD 
         Data      : Tipo_Elemento;  
         Siguiente : Cadena;  
      END RECORD; 

END Iteradores;
