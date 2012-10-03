--  TAD Tabla (implementaci�n 'hash' abierto)
--  Fecha: 2003.03.10
---------------------------------------------------------------

generic

   --  Clave e informaci�n (asignaci�n e igualdad permitidas)
   type Tipo_Clave is private;
   type Tipo_Informacion is limited private;

   --  Tama�o de la tabla
   Tamano : in Positive;
   --  Procedimiento para destruir el tipo de informaci�n
   with function Igualdad (i1, i2 : Tipo_Clave) return Boolean;
   with procedure Destruir (I : in out Tipo_Informacion);
   with procedure Asignacion (A : out Tipo_Informacion;
   B : in Tipo_Informacion);

package Tablas is

   --  No hay igualdad ni asignaci�n predefinidas
   type Tabla is limited private;

   ---------------------------------------------------------------
   Clave_No_Almacenada : exception;
   Tabla_Llena         : exception;


   procedure Crear_Vacia (T : out Tabla);

   ---------------------------------------------------------------
   --  PRE: cierto
   --  POST: Resultado = (T = {})
   --  COMPLEJIDAD: O(Tama�o)
   
   function Es_Vacia (T : in Tabla)
                     return Boolean;

   ---------------------------------------------------------------
   --  PRE: cierto
   --  POST: resultado = (Card(T) = Tama�o)
   --  COMPLEJIDAD: O(Tama�o)
   function Esta_Llena (T : in Tabla)
                       return Boolean;

   ---------------------------------------------------------------
   --  PRE: cierto
   --  POST: Resultado = (E) Tupla EN T � (Tupla = (Clave,_))
   --  COMPLEJIDAD: O(n)
   function Esta (T     : in Tabla;
                  Clave : in Tipo_Clave)
                 return Boolean;

   ---------------------------------------------------------------
   --  PRE:  NOT Esta_Llena(T) \/ Esta(T, Clave)
   --  POST: T^sal = Borrar(T^ent,Clave) U { (Clave,Info) }
   --  EXCEP: Tabla_Llena = Esta_Llena(T^ent) /\ NOT Esta(T^ent, Clave)
   --  COMPLEJIDAD: O(n)
   procedure Almacenar (T     : in out Tabla;
                        Clave : in     Tipo_Clave;
                        Info  : in     Tipo_Informacion);

   ---------------------------------------------------------------
   --  PRE: cierto
   --  POST: T^sal = T^ent - { (Clave,_) }
   --  COMPLEJIDAD: O(n)
   procedure Borrar (T     : in out Tabla;
                     Clave : in     Tipo_Clave);

   ---------------------------------------------------------------
   --  PRE: Esta(T, Clave)
   --  POST: (E) Tupla EN T � (Tupla = (Clave, Resultado))
   --  EXCEP: Clave_No_Almacenada = NOT Esta(T, Clave)
   --  COMPLEJIDAD: O(n)
   function Consulta (T     : in Tabla;
                      Clave : in Tipo_Clave)
                     return Tipo_Informacion;

   ---------------------------------------------------------------
   --  PRE: cierto
   --  POST: T^sal = {} /\
   --        "No libera memoria porque no se usa memoria din�mica"
   --  COMPLEJIDAD: O(Tama�o)
   procedure Destruir_Tabla (T : in out Tabla);

private

   type Tipo_Estado is (Vacia, Ocupada);

   type Tipo_Componente is record
      Clave       : Tipo_Clave;
      Informacion : Tipo_Informacion;
      Estado      : Tipo_Estado      := Vacia;
   end record;

   subtype Tipo_Indice is Natural range 0 .. Tamano - 1;

   type Tabla is array (Tipo_Indice) of Tipo_Componente;

end Tablas;

