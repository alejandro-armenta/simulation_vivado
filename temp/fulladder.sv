module fulladder(

    input logic a, b, cin,

    output logic s, cout

    );
    
    logic p, g;
    
    always_comb begin

        //1 = 1 xor 0

        p = a ^ b;
        
        //0

        g = a & b;
        
        //1

        s = p ^ cin;
        
        //0

        cout = g | p & cin;

    end
    
endmodule


module fulladder_buggy(

    input logic a, b, cin,

    output logic s, cout

    );
    
    logic p, g;
    
    always_comb begin

        p <= a ^ b;
        
        g <= a & b;
        
        s <= p ^ cin;
        
        cout <= g | p & cin;

    end
    
endmodule
