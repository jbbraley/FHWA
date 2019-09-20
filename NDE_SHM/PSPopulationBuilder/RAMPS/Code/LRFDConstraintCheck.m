function ArgOut = LRFDConstraintCheck(ArgIn1, ArgIn2,Parameters)

if Parameters.Spans == 1
    if ArgIn1.Comp == 1;
        % Constraints for compact section
        c(1) = max(Parameters.Length*.032) - (ArgIn1.d + Parameters.Deck.t);
        c(2) = max(Parameters.Length*.027) - ArgIn1.d; 
        c(3) = ArgIn1.Dpst/ArgIn1.Dt - 0.42; 
        c(4) = 0.3125 - ArgIn1.tw;
        c(5) = ArgIn1.ind/ArgIn1.tw - 150; 
        c(6) = ArgIn1.bf/(2*ArgIn1.tf) - 12;
        c(7) = ArgIn1.ind/6 - ArgIn1.bf;
        c(8) = 1.1*ArgIn1.tw - ArgIn1.tf;
        c(9) = ArgIn2.LRFD.fbc_pos(2,:)-0.95*ArgIn1.Fy; 
        c(10) = ArgIn2.LRFD.fbt_pos(2,:)-0.95*ArgIn1.Fy; 
        c(11) = 2*ArgIn1.Dcp/ArgIn1.tw-3.76*sqrt(ArgIn1.E/ArgIn1.Fy); 
        c(12) = max(ArgIn2.LRFD.M_pos)-ArgIn1.Mn_pos; 
        c(13) = max(max(ArgIn2.LRFD.V))-ArgIn1.Vn;
        c(14) = ArgIn2.LRFD.fbc_neg(2,:)-ArgIn1.Fcrw;
        c(15) = ArgIn2.LRFD.fbc_neg(1,:)-ArgIn1.Fn_neg; 
        c(16) = ArgIn2.LRFD.fbt_neg(1,:)-ArgIn1.Fy;
    else
        % Constraints for non-compact section
        c(1) = max(Parameters.Length*.032) - (ArgIn1.d + Parameters.Deck.t);
        c(2) = max(Parameters.Length*.027) - ArgIn1.d; 
        c(3) = ArgIn1.Dpst/ArgIn1.Dt - 0.42; 
        c(4) = 0.3125 - ArgIn1.tw;
        c(5) = ArgIn1.ind/ArgIn1.tw - 150; 
        c(6) = ArgIn1.bf/(2*ArgIn1.tf) - 12;
        c(7) = ArgIn1.ind/6 - ArgIn1.bf;
        c(8) = 1.1*ArgIn1.tw - ArgIn1.tf;
        c(9) = 3.76*sqrt(ArgIn1.E/ArgIn1.Fy)-2*ArgIn1.Dcp/ArgIn1.tw; 
        c(10) = ArgIn2.LRFD.fbc_pos(1,:)-ArgIn1.Fn_pos;
        c(11) = ArgIn2.LRFD.fbt_pos(1,:)-ArgIn1.Fn_pos;
        c(12) = max(max(ArgIn2.LRFD.V))-ArgIn1.Vn;
        c(13) = ArgIn2.LRFD.fbc_neg(2,:)-ArgIn1.Fcrw; 
        c(14) = ArgIn2.LRFD.fbc_neg(1,:)-ArgIn1.Fn_neg; 
        c(15) = ArgIn2.LRFD.fbt_neg(1,:)-ArgIn1.Fy;
    end
else % Spans > 1
    if ArgIn1.CoverPlate.t > 0
        if ArgIn1.Comp == 1
            % Constraints for Compact Section
            c(1) = max(Parameters.Length*.032) - (ArgIn1.d + Parameters.Deck.t); 
            c(2) = max(Parameters.Length*.027) - ArgIn1.d; 
            c(3) = ArgIn1.Dpst/ArgIn1.Dt - 0.42;     
            c(4) = 0.3125 - ArgIn1.tw; 
            c(5) = ArgIn1.ind/ArgIn1.tw - 150; 
            c(6) = ArgIn1.CoverPlate.ind/ArgIn1.tw - 150;   
            c(7) = ArgIn1.bf/(2*ArgIn1.tf) - 12;
            c(8) = ArgIn1.d/6 - ArgIn1.bf;
            c(9) = 1.1*ArgIn1.tw - ArgIn1.tf;
            c(10) = ArgIn1.CoverPlate.bf/(2*ArgIn1.CoverPlate.tf) - 12;
            c(11) = 1.1*ArgIn1.CoverPlate.tw - ArgIn1.CoverPlate.tf;   
            c(12) = ArgIn1.CoverPlate.tf - 3*ArgIn1.tf; 
            c(13) = ArgIn1.tf - ArgIn1.CoverPlate.tf; 
            c(14) = ArgIn2.LRFD.fbc_pos(2,:)-0.95*ArgIn1.Fy; 
            c(15) = ArgIn2.LRFD.fbt_pos(2,:)-0.95*ArgIn1.Fy; 
            c(16) = 2*ArgIn1.Dcp/ArgIn1.tw-3.76*sqrt(ArgIn1.E/ArgIn1.Fy); 
            c(17) = max(ArgIn2.LRFD.M_pos)-ArgIn1.Mn_pos; 
            c(18) = max(max(ArgIn2.LRFD.V))-ArgIn1.Vn;        
            c(19) = ArgIn2.LRFD.fbc_neg(2,:)-ArgIn1.Fcrw;    
            c(20) = ArgIn2.LRFD.fbc_neg(1,:)-ArgIn1.Fn_neg;
            c(21) = ArgIn2.LRFD.fbt_neg(1,:)-ArgIn1.Fy; 
        else
            % Constraints for non-compact section
            c(1) = max(Parameters.Length*.032) - (ArgIn1.d + Parameters.Deck.t); 
            c(2) = max(Parameters.Length*.027) - ArgIn1.d; 
            c(3) = ArgIn1.Dpst/ArgIn1.Dt - 0.42;  
            c(4) = 0.3125 - ArgIn1.tw; 
            c(5) = ArgIn1.ind/ArgIn1.tw - 150; 
            c(6) = ArgIn1.CoverPlate.ind/ArgIn1.tw - 150; 
            c(7) = ArgIn1.bf/(2*ArgIn1.tf) - 12;
            c(8) = ArgIn1.d/6 - ArgIn1.bf;
            c(9) = 1.1*ArgIn1.tw - ArgIn1.tf;
            c(10) = ArgIn1.CoverPlate.bf/(2*ArgIn1.CoverPlate.tf) - 12;
            c(11) = 1.1*ArgIn1.CoverPlate.tw - ArgIn1.CoverPlate.tf;  
            c(12) = ArgIn1.CoverPlate.tf - 3*ArgIn1.tf;
            c(13) = ArgIn1.tf - ArgIn1.CoverPlate.tf;
            c(14) = 3.76*sqrt(ArgIn1.E/ArgIn1.Fy)-2*ArgIn1.Dcp/ArgIn1.tw; 
            c(15) = max(ArgIn2.LRFD.fbc_pos(1,:))-ArgIn1.Fn_pos;
            c(16) = max(ArgIn2.LRFD.fbt_pos(1,:))-ArgIn1.Fn_pos;
            c(17) = max(max(ArgIn2.LRFD.V))-ArgIn1.Vn;
            c(18) = ArgIn2.LRFD.fbc_neg(2,:)-ArgIn1.Fcrw; 
            c(19) = ArgIn2.LRFD.fbc_neg(1,:)-ArgIn1.Fn_neg; 
            c(20) = ArgIn2.LRFD.fbt_neg(1,:)-ArgIn1.Fy;
        end
    else % no cover plate
        if ArgIn1.Comp == 1;
            % Constraints for compact section
            c(1) = max(Parameters.Length*.032) - (ArgIn1.d + Parameters.Deck.t);
            c(2) = max(Parameters.Length*.027) - ArgIn1.d; 
            c(3) = ArgIn1.Dpst/ArgIn1.Dt - 0.42; 
            c(4) = 0.3125 - ArgIn1.tw;
            c(5) = ArgIn1.ind/ArgIn1.tw - 150; 
            c(6) = ArgIn1.bf/(2*ArgIn1.tf) - 12;
            c(7) = ArgIn1.ind/6 - ArgIn1.bf;
            c(8) = 1.1*ArgIn1.tw - ArgIn1.tf;
            c(9) = ArgIn2.LRFD.fbc_pos(2,:)-0.95*ArgIn1.Fy; 
            c(10) = ArgIn2.LRFD.fbt_pos(2,:)-0.95*ArgIn1.Fy; 
            c(11) = 2*ArgIn1.Dcp/ArgIn1.tw-3.76*sqrt(ArgIn1.E/ArgIn1.Fy); 
            c(12) = max(ArgIn2.LRFD.M_pos)-ArgIn1.Mn_pos; 
            c(13) = max(max(ArgIn2.LRFD.V))-ArgIn1.Vn;
            c(14) = ArgIn2.LRFD.fbc_neg(2,:)-ArgIn1.Fcrw;
            c(15) = ArgIn2.LRFD.fbc_neg(1,:)-ArgIn1.Fn_neg; 
            c(16) = ArgIn2.LRFD.fbt_neg(1,:)-ArgIn1.Fy;
        else
            % Constraints for non-compact section
            c(1) = max(Parameters.Length*.032) - (ArgIn1.d + Parameters.Deck.t);
            c(2) = max(Parameters.Length*.027) - ArgIn1.d; 
            c(3) = ArgIn1.Dpst/ArgIn1.Dt - 0.42; 
            c(4) = 0.3125 - ArgIn1.tw;
            c(5) = ArgIn1.ind/ArgIn1.tw - 150; 
            c(6) = ArgIn1.bf/(2*ArgIn1.tf) - 12;
            c(7) = ArgIn1.ind/6 - ArgIn1.bf;
            c(8) = 1.1*ArgIn1.tw - ArgIn1.tf;
            c(9) = 3.76*sqrt(ArgIn1.E/ArgIn1.Fy)-2*ArgIn1.Dcp/ArgIn1.tw; 
            c(10) = ArgIn2.LRFD.fbc_pos(1,:)-ArgIn1.Fn_pos;
            c(11) = ArgIn2.LRFD.fbt_pos(1,:)-ArgIn1.Fn_pos;
            c(12) = max(max(ArgIn2.LRFD.V))-ArgIn1.Vn;
            c(13) = ArgIn2.LRFD.fbc_neg(2,:)-ArgIn1.Fcrw; 
            c(14) = ArgIn2.LRFD.fbc_neg(1,:)-ArgIn1.Fn_neg; 
            c(15) = ArgIn2.LRFD.fbt_neg(1,:)-ArgIn1.Fy;
        end
    end
end

ArgOut = c;
end

 

        

