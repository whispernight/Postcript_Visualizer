-------------------------------------------------------------------------  
--  Visualizador de Ficheros PostScript                                --
-------------------------------------------------------------------------                              
--  010248; Roberto López Masiá; roberto.lopez.masia@hotmail.com       --
--  040289; Andres Gómez Fasbender; fass_centauri@hotmail.com          --
--  050007; Ángel Alférez Aroca; alferez.aroca@gmail.com               --
-------------------------------------------------------------------------


WITH Bloque_Grafico;
USE Bloque_Grafico;

PACKAGE BODY Bloque_Errores IS

   PROCEDURE Procesa_Error (
         Error : IN     Integer ) IS 
   BEGIN
      IF Error = 1 THEN
         Mensaje_Error
            (
            "Fallo del Sistema: contenido del archivo postscript no válido");
         Pclose;
      ELSIF Error = 2 THEN
         Mensaje_Error
            (
            "Fallo del Sistema: Intento de acceso a Pila_Vacia. Faltan argumentos en la pila");
         Pclose;
      ELSIF Error = 3 THEN
         Mensaje_Error
            (
            "Fallo del Sistema: en la pila se ha encontrado un tipo no esperado");
         Pclose;
      ELSIF Error = 4 THEN
         Mensaje_Error
            (
            "Fallo del Sistema: se ha intentado trazar un camino nuevo sin origen definido");
         Pclose;
      ELSIF Error = 5 THEN
         Mensaje_Error ("Fallo del Sistema: no es un archivo PostScript");
         Pclose;
      ELSIF Error = 6 THEN
         Mensaje_Error (
            "Fallo del Sistema: debe especificar que archivo desea abrir");
         Pclose;
      ELSIF Error = 7 THEN
         Mensaje_Error (
            "Fallo del Sistema: el archivo especificado no existe!");
         Pclose;
      ELSIF Error = 8 THEN
         Mensaje_Error (
            "Fin del fichero Postscript!");
         Pclose;
      ELSE
         Mensaje_Error
            ("Faltan argumentos en la pila de estados gráficos");
         Pclose;
      END IF;
   END Procesa_Error;

END Bloque_Errores;
