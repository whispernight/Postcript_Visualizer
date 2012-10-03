with Ada.Text_Io;
use Ada.Text_Io;


-------------------------------------------------------------------------  
--  Visualizador de Ficheros PostScript                                --
-------------------------------------------------------------------------                              
--  010248; Roberto López Masiá; roberto.lopez.masia@hotmail.com       --
--  040289; Andres Gómez Fasbender; fass_centauri@hotmail.com          --
--  050007; Ángel Alférez Aroca; alferez.aroca@gmail.com               --
-------------------------------------------------------------------------
--  Este módulo exporta dos procedimientos que sirven para ocultar o cerrar
--  la ventana destinada a la visualización del archivo postscript.
--
--  Su principal función es leer el fichero postscript cogiendo elemento
--  a elemento evaluando cada uno y llevando a cabo la acción correspondiente.
-- -------------------------------------------------------------------------

package Bloque_Principal is

   procedure ocultar;
--  Oculta la ventana destinada a la visualización del fichero postscript

   procedure cerrar;
--  Cierra la ventana destinada a la visualización del fichero postscript

   procedure leer_postscript (fichero : in String; entrada : in out File_Type; error: in out Integer);
--  Es el programa principal
--  Lee el fichero de entrada, si no se trata de un fichero postscript da
--  un mensaje de error y se termina el programa.
--
--  Si se trata de un fichero postscript ejecuta el programa postscript
--  contenido en el detectando los posibles errores. Si el programa
--  postscript es correcto su visualización aparece en pantalla sino se
--  muestra un mensaje de error.
--
--  La pila de evaluación reside en este procedimiento.Utilizando operaciones
--  del mismo módulo reconoce los operandos y operadores del fichero postscript
--  y lleva a cabo la acción que corresponda: si se trata de añadir o coger
--  operandos de la pila se encarga el mismo, para la construcción de
--  iteradores y para las definiciones nuevas utiliza operaciones del módulo de
--  operaciones y para operaciones gráficas del módulo de pintado.
--   procedure leer_postscript_aux (fichero : in String; entrada : in out File_Type;
--                                    Pila    : in out Pila_Elementos.Pila;
--                                    I       : in out Iterador_Elementos.Iterador;error: in out Integer);

end bloque_principal;