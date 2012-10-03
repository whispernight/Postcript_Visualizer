with Ada.Text_Io;
use Ada.Text_Io;


-------------------------------------------------------------------------  
--  Visualizador de Ficheros PostScript                                --
-------------------------------------------------------------------------                              
--  010248; Roberto L�pez Masi�; roberto.lopez.masia@hotmail.com       --
--  040289; Andres G�mez Fasbender; fass_centauri@hotmail.com          --
--  050007; �ngel Alf�rez Aroca; alferez.aroca@gmail.com               --
-------------------------------------------------------------------------
--  Este m�dulo exporta dos procedimientos que sirven para ocultar o cerrar
--  la ventana destinada a la visualizaci�n del archivo postscript.
--
--  Su principal funci�n es leer el fichero postscript cogiendo elemento
--  a elemento evaluando cada uno y llevando a cabo la acci�n correspondiente.
-- -------------------------------------------------------------------------

package Bloque_Principal is

   procedure ocultar;
--  Oculta la ventana destinada a la visualizaci�n del fichero postscript

   procedure cerrar;
--  Cierra la ventana destinada a la visualizaci�n del fichero postscript

   procedure leer_postscript (fichero : in String; entrada : in out File_Type; error: in out Integer);
--  Es el programa principal
--  Lee el fichero de entrada, si no se trata de un fichero postscript da
--  un mensaje de error y se termina el programa.
--
--  Si se trata de un fichero postscript ejecuta el programa postscript
--  contenido en el detectando los posibles errores. Si el programa
--  postscript es correcto su visualizaci�n aparece en pantalla sino se
--  muestra un mensaje de error.
--
--  La pila de evaluaci�n reside en este procedimiento.Utilizando operaciones
--  del mismo m�dulo reconoce los operandos y operadores del fichero postscript
--  y lleva a cabo la acci�n que corresponda: si se trata de a�adir o coger
--  operandos de la pila se encarga el mismo, para la construcci�n de
--  iteradores y para las definiciones nuevas utiliza operaciones del m�dulo de
--  operaciones y para operaciones gr�ficas del m�dulo de pintado.
--   procedure leer_postscript_aux (fichero : in String; entrada : in out File_Type;
--                                    Pila    : in out Pila_Elementos.Pila;
--                                    I       : in out Iterador_Elementos.Iterador;error: in out Integer);

end bloque_principal;