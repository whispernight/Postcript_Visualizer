-------------------------------------------------------------------------  
--  Visualizador de Ficheros PostScript                                --
-------------------------------------------------------------------------                              
--  010248; Roberto López Masiá; roberto.lopez.masia@hotmail.com       --
--  040289; Andres Gómez Fasbender; fass_centauri@hotmail.com          --
--  050007; Ángel Alférez Aroca; alferez.aroca@gmail.com               --
-------------------------------------------------------------------------



WITH Ada.Unchecked_Deallocation;

PACKAGE BODY Iteradores IS

   PROCEDURE Liberar_Memoria IS 
   NEW Ada.Unchecked_Deallocation (
      Object => Nodo,  
      Name   => Cadena);

   PROCEDURE Crear_Iterador (
         I :    OUT Iterador ) IS 
   BEGIN
      I.Primero := NULL;
      I.Actual := NULL;
      I.Ultimo := NULL;
   END Crear_Iterador;

   FUNCTION Es_Vacio (
         I : IN     Iterador ) 
     RETURN Boolean IS 
   BEGIN
      RETURN I.Primero = NULL;
   END Es_Vacio;

   PROCEDURE Insertar_Dato (
         E : IN     Tipo_Elemento; 
         I : IN OUT Iterador       ) IS 
      Aux : Cadena;  
   BEGIN
      Aux := I.Primero;
      IF Aux = NULL THEN
         I.Primero := NEW Nodo'(
            Data      => E,   
            Siguiente => NULL);
      ELSE
         WHILE Aux.ALL.Siguiente /= NULL LOOP
            Aux := Aux.ALL.Siguiente;
         END LOOP;
         Aux.ALL.Siguiente := NEW Nodo'(
            Data      => E,   
            Siguiente => NULL);
      END IF;
      IF I.Ultimo = NULL THEN
         I.Ultimo := I.Primero;
      ELSE
         I.Ultimo := I.Ultimo.ALL.Siguiente;
      END IF;
   END Insertar_Dato;

   PROCEDURE Iniciar (
         I : IN OUT Iterador ) IS 
   BEGIN
      I.Actual := I.Primero;
   END Iniciar;

   FUNCTION Hay_Siguiente (
         I : Iterador ) 
     RETURN Boolean IS 
   BEGIN
      RETURN NOT (I.Actual.ALL.Siguiente = NULL);
   END Hay_Siguiente;

   PROCEDURE Siguiente (
         I : IN OUT Iterador ) IS 
   BEGIN
      I.Actual := I.Actual.ALL.Siguiente;
   END Siguiente;

   FUNCTION Dato_Actual (
         I : Iterador ) 
     RETURN Tipo_Elemento IS 
   BEGIN
      RETURN I.Actual.ALL.Data;
   END Dato_Actual;

   PROCEDURE Destruir (
         I : IN OUT Iterador ) IS 
      Ref_I : Iterador;  
   BEGIN
      WHILE I.Primero /= NULL LOOP
         Ref_I.Primero := I.Primero;
         I.Primero := I.Primero.ALL.Siguiente;
         Liberar_Memoria (Ref_I.Primero);
      END LOOP;
   END Destruir;

   PROCEDURE Asignar (
         A :    OUT Iterador; 
         B : IN     Iterador  ) IS 
   BEGIN
      A := B;
   END Asignar;

END Iteradores;