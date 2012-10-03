This program has been coded in Ada95 languaje.
As its name says, its a postcript visualizer.


Explanation (Spanish):


Un documento PostScript, en realidad, es un peque�o programa que le dice a una m�quina qu�, c�mo y d�nde imprimir, paso a paso. Los documentos PostScript se destinan a imprimirse en aparatos PostScript, es decir, en aparatos que tienen un dispositivo interno capaz de descifrar el c�digo que reciben y convertirlo en simples puntos de impresi�n (aqu� imprimo, aqu� no, aqu� s�, aqu� tambi�n, etc�). 
Para ser adaptable, PostScript es un lenguaje de los denominados "interpretados". Es decir, no le habla directamente a la m�quina, sino que necesita un procesador (un dispositivo f�sico o un programa residente en el ordenador) que act�e como int�rprete traductor entre el c�digo PostScript universal y la m�quina. Eso es lo que se llama "int�rprete PostScript".
De hecho, el lenguaje PostScript es tan "universal" que su forma m�s sencilla son simples instrucciones escritas como textos (siguiendo, eso s�, una sintaxis muy rigurosa). B�sicamente un fichero PostScript contiene instrucciones que, traducidas al lenguaje humano, dicen cosas del tipo: traza un c�rculo de 3 cm  de radio, dibuja una l�nea de 4,5 cm. en un �ngulo de 45 grados, etc�
Por lo que nuestro programa es un "simple int�rprete PostScript ", debe traducir est�s instrucciones hasta llegar a la impresi�n en pantalla de la mismas.


Pruebas: Contains all the test and results done to the code.

Documentacion: Contains a memory explaining the code.

Codigo: Contains the code of the program.

Author: Angel Alferez Aroca