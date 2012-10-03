-------------------------------------------------------------------------  
--  Visualizador de Ficheros PostScript                                --
-------------------------------------------------------------------------                              
--  010248; Roberto L�pez Masi�; roberto.lopez.masia@hotmail.com       --
--  040289; Andres G�mez Fasbender; fass_centauri@hotmail.com          --
--  050007; �ngel Alf�rez Aroca; alferez.aroca@gmail.com               --
-------------------------------------------------------------------------
--     Este programa coge de la entrada est�ndar el nombre del fichero
--  postscript que se desea ejecutar. Oculta la visualizaci�n del fichero
--  postscript y cierra esta en caso de error, la visualizaci�n se mostrar�
--  m�s adelante si el archivo es correcto y aparece la sentencia "showpage"
--  en el fichero postscript
-- -------------------------------------------------------------------------
with bloque_principal;
USE bloque_principal;
with bloque_errores;
use bloque_errores;
with Ada.Command_Line;
use Ada.Command_Line;
with Ada.Text_IO;
USE Ada.Text_IO;
with Ada.Integer_Text_IO;
use Ada.Integer_Text_IO;

--  PRE: Cierto
--  POST: Oculta la visualizaci�n del fichero postscript.
--        Si recibe un argumento correspondiente a un archivo postscript
--        procede a leer este fichero. Si no recibe ning�n argumento
--        cierra la ventana destinada a visualizar el fichero postscript.
PROCEDURE Visualps IS
   Error:Integer:=0;
   Entrada : File_Type;
begin
   
   if Argument_Count = 0 then
      Error := 6;      
   ELSIF (Argument(1)="-h" OR Argument(1)="-help") THEN
      Put_line ("Visualizador de archivos PostScript"); 
      Put ("practica de EDII:: alumnos Andres Gomez, Angel Alferez y Roberto Lopez");
      New_Line;
      New_Line;
      Put("Forma de utilizaci�n:");
      New_Line;
      put("visualps archivo_postscript.ps");
      New_Line;
      cerrar;
   ELSif Argument_Count = 1 then
      Ocultar;
      Leer_Postscript (Argument (1), Entrada, Error);
      put("Estado de salida: ");
      put(error);
      cerrar;
   end if;
   IF Error/=0 THEN
      Procesa_Error(Error);
      Cerrar;
   END IF;
end Visualps;
   