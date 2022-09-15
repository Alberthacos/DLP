
// Declaracionn de las compuertas basicas
// Autor: Juan Antonio Jaramillo Gomez
module funciones (
input wire a, b, c, // Entradas a, b y c
output wire s1, // declaracion de las salidas
output wire s2,
output wire s3,
output wire s4,
output wire s5,
output wire s6
) ; // completar las otras 3 salidas
assign s1 = a ^ b ^ c; // 
assign s2 = a | b | c; // 
assign s3 = ~( a ^ b ); //  
assign s4 = ~(b | c);
assign s5 = (~(a & c)) | b;
assign s6 = (a & b) | c; 
endmodule