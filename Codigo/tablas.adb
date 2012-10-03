
package body Tablas is


   procedure Crear_Vacia (T : out Tabla) is
   begin
      for K in Tipo_Indice loop
         T (K).Estado := Vacia;
      end loop;
   end Crear_Vacia;

   function Es_Vacia (T : Tabla)
                     return Boolean is
      K : Tipo_Indice := 0;
   begin
      while  (K < Tamano - 1) and then (T (K).Estado /= Ocupada) loop
         K := K + 1;
      end loop;
      return T (K).Estado /= Ocupada;
   end Es_Vacia;


   function Esta_Llena (T : Tabla)
                       return Boolean is
      K : Tipo_Indice := 0;
   begin
      while (K < Tamano - 1) and (T (K).Estado = Ocupada) loop
         K := K + 1;
      end loop;
      return T (K).Estado = Ocupada;
   end Esta_Llena;


   function Esta (T     : Tabla;
                  Clave : Tipo_Clave)
                 return Boolean is
      x : Boolean := False;
   begin
  
      for i in Tipo_Indice loop
         if Igualdad (T (i).Clave, Clave) and T (i).Estado = Ocupada then
            x := True;
         end if;
      end loop;
      return x;
   end Esta;

   procedure Almacenar (T     : in out Tabla;
                        Clave : in     Tipo_Clave;
                        Info  : in     Tipo_Informacion) is
      n : Integer := -1;
      m : Integer := 0;
   begin

      while m <= (Tamano - 1) loop
         if T (m).Estado /= Ocupada then n := m;
            exit;
         end if;
         m := m + 1;
      end loop;
      T (n).Clave := Clave;
      Asignacion (T (n).Informacion, Info);
      T (n).Estado := Ocupada;

   end Almacenar;


   function Consulta (T     : in Tabla;
                      Clave : in Tipo_Clave)
                     return Tipo_Informacion is
      n : Integer := -1;
      m : Integer := 0;
   begin
   
      while m <= (Tamano - 1) loop
         if Igualdad (T (m).Clave, Clave) then n := m;
            exit;
         end if;
         m := m + 1;
      end loop;
      
      return T (n).Informacion;
   
   end Consulta;

   procedure Borrar (T     : in out Tabla;
                     Clave : in     Tipo_Clave) is
      n : Integer := -1;
      m : Integer := 0;
   begin
   
      while m <= (Tamano - 1) loop
         if Igualdad (T (m).Clave, Clave) then n := m;
            exit;
         end if;
         m := m + 1;
      end loop;
      if n /= -1 then
         T (n).Estado := Vacia;
         Destruir (T (n).Informacion);
      end if;
   end Borrar;

   procedure Destruir_Tabla (T : in out Tabla) is
   begin
      for K in Tipo_Indice loop
         if T (K).Estado /= Vacia then T (K).Estado := Vacia;
            Destruir (T (K).Informacion);
         end if;
      end loop;
   end Destruir_Tabla;

end Tablas;
